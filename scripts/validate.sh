#!/bin/bash
# Validate all skills in the repository
# Checks for required files and proper structure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$REPO_ROOT/skills"

echo "🔍 Validating skills in $SKILLS_DIR"
echo "========================================"

errors=0
warnings=0

# Check each skill directory
for skill_dir in "$SKILLS_DIR"/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo ""
        echo "📦 Checking: $skill_name"
        
        # Check for SKILL.md (required)
        if [ -f "$skill_dir/SKILL.md" ]; then
            echo "  ✓ SKILL.md exists"
            
            # Check for YAML frontmatter
            if head -1 "$skill_dir/SKILL.md" | grep -q "^---"; then
                echo "  ✓ YAML frontmatter present"
                
                # Check for name field
                if grep -q "^name:" "$skill_dir/SKILL.md"; then
                    echo "  ✓ name field found"
                else
                    echo "  ✗ name field missing in SKILL.md"
                    errors=$((errors + 1))
                fi
                
                # Check for description field
                if grep -q "^description:" "$skill_dir/SKILL.md"; then
                    echo "  ✓ description field found"
                else
                    echo "  ✗ description field missing in SKILL.md"
                    errors=$((errors + 1))
                fi
            else
                echo "  ✗ YAML frontmatter missing (should start with ---)"
                errors=$((errors + 1))
            fi
        else
            echo "  ✗ SKILL.md missing (required)"
            errors=$((errors + 1))
        fi
        
        # Check for README.md
        if [ -f "$skill_dir/README.md" ]; then
            echo "  ✓ README.md exists"
        else
            echo "  ⚠ README.md missing (recommended)"
            warnings=$((warnings + 1))
        fi
        
        # Check for dependency file
        if [ -f "$skill_dir/pyproject.toml" ] || [ -f "$skill_dir/package.json" ]; then
            echo "  ✓ Dependency file exists"
        else
            echo "  ⚠ No dependency file (pyproject.toml or package.json)"
            warnings=$((warnings + 1))
        fi
        
        # Check for evals directory (recommended)
        if [ -d "$skill_dir/evals" ]; then
            echo "  ✓ evals/ directory exists"
        else
            echo "  ℹ No evals/ directory (optional)"
        fi
    fi
done

echo ""
echo "========================================"
echo "Validation Summary:"
echo "  Errors: $errors"
echo "  Warnings: $warnings"
echo "========================================"

if [ $errors -gt 0 ]; then
    echo "❌ Validation failed with $errors error(s)"
    exit 1
else
    echo "✅ Validation passed!"
    exit 0
fi
