#!/usr/bin/env node

/**
 * Generates README.md from issue files by reading their frontmatter and titles.
 * Run this script whenever issues are added, removed, or status changes.
 * 
 * Usage:
 *   node generate-readme.js
 * 
 * Or add to git hook:
 *   echo 'node issues/generate-readme.js' >> .git/hooks/pre-commit
 */

const fs = require('fs');
const path = require('path');

const ISSUES_DIR = __dirname;
const README_PATH = path.join(ISSUES_DIR, 'README.md');
const DONE_DIR = path.join(ISSUES_DIR, 'done');

// Status categories in order
const STATUS_ORDER = ['in-progress', 'backlog', 'blocked', 'done'];
const STATUS_LABELS = {
  'in-progress': 'In Progress',
  'backlog': 'Backlog',
  'blocked': 'Blocked',
  'done': 'Done',
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

function getIssueFiles() {
  // Get active issues from main directory
  const activeFiles = fs.readdirSync(ISSUES_DIR)
    .filter(file => file.endsWith('.md') && file !== 'README.md' && file !== '_template.md')
    .map(file => ({
      filename: file,
      path: path.join(ISSUES_DIR, file),
      number: file.match(/^(\d+)/)?.[1],
      isDone: false,
    }))
    .filter(file => file.number); // Only numbered issues
  
  // Get done issues from done/ directory
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

function readIssue(file) {
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
  };
}

function generateREADME(issues) {
  // Group issues by status
  const byStatus = {};
  STATUS_ORDER.forEach(status => {
    byStatus[status] = [];
  });
  
  issues.forEach(issue => {
    if (byStatus[issue.status]) {
      byStatus[issue.status].push(issue);
    } else {
      console.warn(`Warning: Unknown status "${issue.status}" in ${issue.filename}`);
    }
  });
  
  // Generate README content
  let content = `# Issues

Quick reference for active tasks. See individual files for details.

> **Note:** This README is auto-generated from issue files. To regenerate it, run:
> \`\`\`bash
> node issues/generate-readme.js
> \`\`\`

`;

  // Generate sections for each status
  STATUS_ORDER.forEach(status => {
    const label = STATUS_LABELS[status];
    const statusIssues = byStatus[status];
    
    content += `## ${label}\n`;
    if (statusIssues.length === 0) {
      content += `(none)\n\n`;
    } else {
      statusIssues.forEach(issue => {
        content += `- [${issue.number}](${issue.filename}) - ${issue.title}\n`;
      });
      content += `\n`;
    }
  });
  
  // Add footer with reference info
  content += `---

## Status Values
- \`backlog\` - Not started yet
- \`in-progress\` - Currently working on this
- \`blocked\` - Waiting on something else
- \`done\` - Completed (move to \`done/\` folder)

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
  const issueFiles = getIssueFiles();
  const issues = issueFiles
    .map(readIssue)
    .filter(issue => issue !== null);
  
  const readmeContent = generateREADME(issues);
  fs.writeFileSync(README_PATH, readmeContent, 'utf-8');
  
  const totalIssues = issues.length;
  const doneCount = issues.filter(i => i.status === 'done').length;
  const activeCount = totalIssues - doneCount;
  
  console.log(`✅ Generated README.md with ${totalIssues} issue(s) (${activeCount} active, ${doneCount} done)`);
  console.log(`   Status breakdown:`);
  STATUS_ORDER.forEach(status => {
    const count = issues.filter(i => i.status === status).length;
    if (count > 0) {
      console.log(`   - ${STATUS_LABELS[status]}: ${count}`);
    }
  });
} catch (error) {
  console.error('Error generating README:', error);
  process.exit(1);
}

