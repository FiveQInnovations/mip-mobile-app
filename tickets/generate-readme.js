#!/usr/bin/env node

/**
 * Generates README.md from ticket files by reading their frontmatter and titles.
 * Run this script whenever tickets are added, removed, or status changes.
 * 
 * Usage:
 *   node generate-readme.js
 * 
 * Or add to git hook:
 *   echo 'node tickets/generate-readme.js' >> .git/hooks/pre-commit
 */

const fs = require('fs');
const path = require('path');

const TICKETS_DIR = __dirname;
const README_PATH = path.join(TICKETS_DIR, 'README.md');
const DONE_DIR = path.join(TICKETS_DIR, 'done');

// Status categories in order
const STATUS_ORDER = ['qa', 'in-progress', 'backlog', 'blocked', 'maybe', 'done'];
const STATUS_LABELS = {
  'qa': 'QA',
  'in-progress': 'In Progress',
  'backlog': 'Backlog',
  'blocked': 'Blocked',
  'maybe': 'Maybe',
  'done': 'Done',
};

// Phase categories for backlog grouping
const PHASE_ORDER = ['core', 'nice-to-have', 'c4i', 'production', 'testing'];
const PHASE_LABELS = {
  'core': '🔴 Core Functionality (FFCI)',
  'nice-to-have': '🟡 Nice to Have',
  'c4i': '🟣 C4I Phase',
  'production': '🟢 Production Ready',
  'testing': '📋 Testing',
};

function parseFrontmatter(content) {
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);
  if (!frontmatterMatch) return null;
  
  const frontmatter = {};
  frontmatterMatch[1].split('\n').forEach(line => {
    const match = line.match(/^(\w+):\s*(.+)$/);
    if (match) {
      frontmatter[match[1]] = match[2].trim();
    }
  });
  
  return frontmatter;
}

function extractTitle(content) {
  const titleMatch = content.match(/^#\s+(.+)$/m);
  return titleMatch ? titleMatch[1] : 'Untitled';
}

function getTicketFiles() {
  // Get active tickets from main directory
  const activeFiles = fs.readdirSync(TICKETS_DIR)
    .filter(file => file.endsWith('.md') && file !== 'README.md' && file !== '_template.md')
    .map(file => ({
      filename: file,
      path: path.join(TICKETS_DIR, file),
      number: file.match(/^(\d+)/)?.[1],
      isDone: false,
    }))
    .filter(file => file.number); // Only numbered tickets
  
  // Get done tickets from done/ directory
  const doneFiles = fs.existsSync(DONE_DIR) 
    ? fs.readdirSync(DONE_DIR)
        .filter(file => file.endsWith('.md') && file !== 'README.md')
        .map(file => ({
          filename: `done/${file}`,
          path: path.join(DONE_DIR, file),
          number: file.match(/^(\d+)/)?.[1],
          isDone: true,
        }))
        .filter(file => file.number)
    : [];
  
  // Combine and sort by number
  const allFiles = [...activeFiles, ...doneFiles]
    .sort((a, b) => parseInt(a.number) - parseInt(b.number));
  
  return allFiles;
}

function readTicket(file) {
  const content = fs.readFileSync(file.path, 'utf-8');
  const frontmatter = parseFrontmatter(content);
  const title = extractTitle(content);
  
  // If file is in done/ folder, treat as done status
  const status = file.isDone ? 'done' : (frontmatter?.status || 'backlog');
  
  if (!frontmatter) {
    console.warn(`Warning: ${file.filename} missing frontmatter`);
  }
  
  return {
    number: file.number,
    filename: file.filename,
    title,
    status,
    area: frontmatter?.area || 'general',
    phase: frontmatter?.phase || null,
  };
}

function generateREADME(tickets) {
  // Group tickets by status
  const byStatus = {};
  STATUS_ORDER.forEach(status => {
    byStatus[status] = [];
  });
  
  tickets.forEach(ticket => {
    if (byStatus[ticket.status]) {
      byStatus[ticket.status].push(ticket);
    } else {
      console.warn(`Warning: Unknown status "${ticket.status}" in ${ticket.filename}`);
    }
  });
  
  // Generate README content
  let content = `# Tickets

Quick reference for active tasks. See individual files for details.

> **Note:** This README is auto-generated from ticket files. To regenerate it, run:
> \`\`\`bash
> node tickets/generate-readme.js
> \`\`\`

`;

  // Generate sections for each status
  STATUS_ORDER.forEach(status => {
    const label = STATUS_LABELS[status];
    const statusTickets = byStatus[status];
    
    content += `## ${label}\n`;
    if (statusTickets.length === 0) {
      content += `(none)\n\n`;
    } else if (status === 'backlog') {
      // Group backlog by phase
      const byPhase = {};
      PHASE_ORDER.forEach(phase => {
        byPhase[phase] = [];
      });
      byPhase['unassigned'] = [];
      
      statusTickets.forEach(ticket => {
        if (ticket.phase && byPhase[ticket.phase]) {
          byPhase[ticket.phase].push(ticket);
        } else {
          byPhase['unassigned'].push(ticket);
        }
      });
      
      // Output each phase that has tickets
      PHASE_ORDER.forEach(phase => {
        if (byPhase[phase].length > 0) {
          content += `\n### ${PHASE_LABELS[phase]}\n`;
          byPhase[phase].forEach(ticket => {
            content += `- [${ticket.number}](${ticket.filename}) - ${ticket.title}\n`;
          });
        }
      });
      
      // Output unassigned if any
      if (byPhase['unassigned'].length > 0) {
        content += `\n### Unassigned\n`;
        byPhase['unassigned'].forEach(ticket => {
          content += `- [${ticket.number}](${ticket.filename}) - ${ticket.title}\n`;
        });
      }
      content += `\n`;
    } else {
      statusTickets.forEach(ticket => {
        content += `- [${ticket.number}](${ticket.filename}) - ${ticket.title}\n`;
      });
      content += `\n`;
    }
  });
  
  // Add footer with reference info
  content += `---

## Status Values
- \`qa\` - Ready for review/QA, review before starting new work
- \`backlog\` - Not started yet
- \`in-progress\` - Currently working on this
- \`blocked\` - Waiting on something else
- \`maybe\` - Low priority, revisit later
- \`done\` - Completed (move to \`done/\` folder)

## Phases (for backlog prioritization)
- \`core\` - Core functionality, fix first
- \`nice-to-have\` - Polish, not blocking launch
- \`c4i\` - C4I-specific, after FFCI launch
- \`production\` - Final tasks before App Store submission
- \`testing\` - Ongoing test coverage

## Areas
- \`rn-mip-app\` - React Native mobile app
- \`wsp-mobile\` - Kirby plugin for mobile API
- \`ws-ffci-copy\` - Kirby site configuration
- \`astro-prototype\` - Astro PWA prototype
- \`general\` - Cross-cutting or repo-level tasks

`;

  return content;
}

// Main execution
try {
  const ticketFiles = getTicketFiles();
  const tickets = ticketFiles
    .map(readTicket)
    .filter(ticket => ticket !== null);
  
  const readmeContent = generateREADME(tickets);
  fs.writeFileSync(README_PATH, readmeContent, 'utf-8');
  
  const totalTickets = tickets.length;
  const doneCount = tickets.filter(i => i.status === 'done').length;
  const activeCount = totalTickets - doneCount;
  
  console.log(`✅ Generated README.md with ${totalTickets} ticket(s) (${activeCount} active, ${doneCount} done)`);
  console.log(`   Status breakdown:`);
  STATUS_ORDER.forEach(status => {
    const count = tickets.filter(i => i.status === status).length;
    if (count > 0) {
      console.log(`   - ${STATUS_LABELS[status]}: ${count}`);
    }
  });
} catch (error) {
  console.error('Error generating README:', error);
  process.exit(1);
}

