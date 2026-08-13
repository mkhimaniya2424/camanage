import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix TextStyle(textMuted, etc) -> TextStyle(color: colors.textMuted,
    content = re.sub(
        r'TextStyle\((text[A-Za-z]+|primary[A-Za-z]*|secondary|tertiary|error[A-Za-z]*|bg[0-9]|glass[A-Za-z]*|success|warning)', 
        r'TextStyle(color: colors.\1', 
        content
    )

    # Fix Icon(textDisabled) in profile_screen.dart
    content = content.replace('Icon(textDisabled)', 'Icon(Icons.lock_outline, size: 14, color: colors.textDisabled)')
    
    # Fix Icon(textSecondary) and others if they exist
    # There's 'Icon(textSecondary' ? Let's just fix it generally if found:
    # Actually, flutter analyze didn't show more Icon errors.

    # Inject colors into helper methods that need them
    missing_context_methods = [
        'void _showSnack(String message, {bool success = false}) {',
        'Future<void> _showChangePasswordDialog() async {',
        'Widget _buildAvatarSection(Profile profile) {',
        'Color _roleColor(UserRole role) {',
        'Widget _buildLogoSection() {', # firm_settings_screen
        'Widget _buildPlanBadge() {', # firm_settings_screen
        'void _showSnack(String message, {bool success = false}) {', # firm_settings_screen
        'Widget _buildWelcomeCard(String email, UserRole role) {', # dashboard
        'Widget _buildStatGrid() {', # dashboard
        'Widget _buildStatCard(_StatItem stat) {', # dashboard
        'Widget _buildModulesPreview() {', # dashboard
        'Widget _buildBottomNav() {', # dashboard
        'Color _roleColor(UserRole role) {', # dashboard
    ]
    
    for m in set(missing_context_methods):
        if m in content and 'final colors = context.appColors;' not in content.split(m)[1].split('}')[0]:
            content = content.replace(m, m + '\n    final colors = context.appColors;')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))
