require 'rubygems'

iterations = 100
test_file = "#{File.dirname(__FILE__)}/benchmark.txt"
implementations = %w[BlueCloth RDiscount Maruku Markdown]

# Attempt to require each implementation and remove any that are not
# installed.
implementations.reject! do |class_name|
  begin
    require class_name.downcase
    false
  rescue LoadError => boom
    puts "#{class_name} excluded from benchmark. (Try: gem install #{class_name.downcase})"
    true
  end
end

# Grab actual class objects.
implementations.map! { |class_name| Object.const_get(class_name) }

# The actual benchmark.
def benchmark(implementation, text, iterations)
  start = Time.now
  iterations.times do |i|
    implementation.new(text).to_html
  end
  Time.now - start
end

# Read test file
test_data = File.read(test_file)

# Prime the pump
puts "Spinning up ..."
implementations.each { |impl| benchmark(impl, test_data, 1) }

# Run benchmarks; gather results.
puts "Running benchmarks ..."
results =
  implementations.inject([]) do |r,impl|
    GC.start
    r << [ impl, benchmark(impl, test_data, iterations) ]
  end

puts "Results for #{iterations} iterations:"
results.each do |impl,time|
  printf "  %10s %09.06fs total time, %09.06fs average\n", "#{impl}:", time, time / iterations
end
