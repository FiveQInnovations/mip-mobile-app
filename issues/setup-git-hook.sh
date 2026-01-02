#!/bin/bash

# Optional: Set up git hook to auto-generate README on commit
# This ensures README stays in sync with issue files

HOOK_PATH=".git/hooks/pre-commit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/generate-readme.js"

if [ ! -d ".git" ]; then
  echo "❌ Not in a git repository"
  exit 1
fi

# Check if hook already exists
if [ -f "$HOOK_PATH" ]; then
  if grep -q "generate-readme.js" "$HOOK_PATH"; then
    echo "✅ Git hook already configured"
    exit 0
  fi
  echo "⚠️  Pre-commit hook exists. Appending to it..."
  echo "" >> "$HOOK_PATH"
  echo "# Auto-generate issues README" >> "$HOOK_PATH"
  echo "node \"$SCRIPT_PATH\"" >> "$HOOK_PATH"
  echo "git add issues/README.md" >> "$HOOK_PATH"
else
  echo "📝 Creating pre-commit hook..."
  cat > "$HOOK_PATH" << 'EOF'
#!/bin/bash
# Auto-generate issues README
EOF
  echo "node \"$SCRIPT_PATH\"" >> "$HOOK_PATH"
  echo "git add issues/README.md" >> "$HOOK_PATH"
  chmod +x "$HOOK_PATH"
fi

echo "✅ Git hook configured!"
echo ""
echo "The README will now be auto-generated before each commit."
echo "To disable, edit .git/hooks/pre-commit"

