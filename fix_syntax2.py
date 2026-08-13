import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Fix AppShadows
    content = content.replace('AppShadows.button', 
        '[BoxShadow(color: colors.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4))]')
    content = content.replace('AppShadows.card', 
        '[BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8))]')
    content = content.replace('AppShadows.glow', 
        '[BoxShadow(color: colors.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))]')

    # 2. Fix remaining const issues
    # Any `const Text(..., style: TextStyle(color: colors...))` -> remove const
    content = re.sub(r'const\s+(Text\([^)]*colors\.[^)]*\))', r'\1', content)
    # Any `const [ _StatItem(..., color: colors... ) ]` -> remove const from array
    content = re.sub(r'const\s+(\[\s*_[A-Za-z0-9_]+\([^\]]*colors\.[^\]]*\])', r'\1', content)
    # Any `const Padding(..., child: ...colors...)` 
    # Just run a general strip: `const ` followed by anything on the same line that has `colors.`
    # This is tricky with regex across lines.
    # Let's just fix the specific files.
    
    # 3. Fix missing colors in firm_settings_screen
    content = content.replace("Icon(warning", "Icon(Icons.warning, color: colors.warning")
    content = content.replace("Icon(primary", "Icon(Icons.info, color: colors.primary")
    content = content.replace("Icon(secondary", "Icon(Icons.info, color: colors.secondary")
    content = content.replace("Icon(error", "Icon(Icons.error, color: colors.error")
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))
