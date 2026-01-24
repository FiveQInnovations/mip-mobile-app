# Kirby Page-content JSON Editing Guide

This guide documents learnings from editing the complex `Page-content` JSON field in Kirby CMS pages.

The `Page-content` field is a page builder that stores content as a single-line JSON array. It's difficult to read and easy to break.

---

## General Rules

1. **Never pretty-print** - Keep JSON on a single line
2. **One change at a time** - Make small, surgical edits
3. **Test locally first** - Verify via DDEV before pushing
4. **Backup the original** - Copy the original JSON before editing

---

## Learnings Log

> Add entries here as you learn what works and what breaks.

### Template Entry

```markdown
## YYYY-MM-DD: [Task Description]

**Task:** [What you were trying to do]

**What worked:**
- [Approach that succeeded]

**What broke (if anything):**
- [What went wrong and why]

**Pattern learned:**
- [Key takeaway for future edits]
```

---

## Known Patterns

### Safe Operations

- Changing text content within `"text"` fields
- Updating button labels
- Modifying heading text
- Changing color values

### Risky Operations

- Adding new blocks (complex structure)
- Removing blocks (may break references)
- Changing block types
- Modifying IDs (can break links)

---

## Block Type Reference

| Type | Purpose | Key Fields |
|------|---------|------------|
| `heading` | h1-h6 text | `level`, `text`, `text_align` |
| `text` | Rich text content | `text`, `text_align`, `text_size` |
| `image` | Image display | `image`, `alt`, `caption` |
| `background` | Section backgrounds | `background_color`, `image`, `media_opacity` |
| `buttongroup` | Button collections | `buttons` (nested JSON) |
| `button` | Individual buttons | `text`, `link_to`, `url`, `page` |

---

## Troubleshooting

### Page won't load after edit

1. Check for missing commas or quotes
2. Verify JSON is valid (use a JSON validator)
3. Restore from git: `git checkout -- content/path/default.txt`

### Changes don't appear

1. Clear Kirby cache: `rm -rf storage/cache/*` (via DDEV)
2. Hard refresh browser
3. Check if editing correct file
