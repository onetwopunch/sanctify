require 'pry'
Pry.config.prompt = lambda do |context, nesting, pry|
  "[sanctify] #{context}> "
end

### Add extra console config here
