all

# I like to have the title slightly belower
# rule 'MD012', :maximum => 3 (this line does not work)
exclude_rule 'MD012'

# This rule doesn't seem to work
rule 'MD029', :style => 'ordered'

# Longer lines, like the initial setup
rule 'MD013', :line_length => 90, :ignore_code_blocks => true, :tables => false
