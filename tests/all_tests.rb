test_dir = File.dirname __FILE__

Dir.chdir(test_dir) do
  Dir.glob('**/test_*.rb') { |test_case| puts File.join(test_dir, test_case); require File.join(test_dir, test_case) }
end
