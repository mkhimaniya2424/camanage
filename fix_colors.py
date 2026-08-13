import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Inject `final colors = context.appColors;` in build methods
    build_pattern = re.compile(r'(Widget build\(BuildContext context\)\s*\{)')
    if not re.search(r'final colors = context\.appColors;', content):
        content = build_pattern.sub(r'\1\n    final colors = context.appColors;', content)

    # Some helper methods like _buildLogoSection() in firm_settings don't have context in the signature
    # but they are in State class, so context is available. Let's just blindly replace `const ` with `` near `colors.` usages
    # A bit risky but faster. Actually, I can write a regex to remove const from BoxDecoration, LinearGradient, RadialGradient, TextStyle, etc.
    const_patterns = [
        r'const\s+(BoxDecoration\([^)]*colors\.)',
        r'const\s+(LinearGradient\([^)]*colors\.)',
        r'const\s+(RadialGradient\([^)]*colors\.)',
        r'const\s+(TextStyle\([^)]*colors\.)',
        r'const\s+(BorderSide\([^)]*colors\.)',
        r'const\s+(Icon\([^)]*colors\.)',
        r'const\s+(\[\s*colors\.)',
    ]
    for _ in range(3): # repeat to catch nested
        content = re.sub(r'const\s+BoxDecoration', 'BoxDecoration', content)
        content = re.sub(r'const\s+LinearGradient', 'LinearGradient', content)
        content = re.sub(r'const\s+RadialGradient', 'RadialGradient', content)
        content = re.sub(r'const\s+TextStyle\([^)]*colors\.', 'TextStyle(', content) # specialized
        content = re.sub(r'const\s+Icon\([^)]*colors\.', 'Icon(', content) 
        
    # Remove const arrays that have colors in them
    content = re.sub(r'const\s+\[([^\]]*colors\.[^\]]*)\]', r'[\1]', content)

    # State helpers might need colors:
    # If there's `colors.` in a method that isn't `build`, we might need `final colors = context.appColors;`
    methods_with_colors = re.findall(r'(Widget\s+_[a-zA-Z0-9_]+\s*\([^)]*\)\s*\{)', content)
    for m in set(methods_with_colors):
        if 'final colors = context.appColors;' not in content.split(m)[1].split('}')[0]:
            content = content.replace(m, m + '\n    final colors = context.appColors;')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart') and 'app_widgets' not in file and 'app_theme' not in file:
            fix_file(os.path.join(root, file))
