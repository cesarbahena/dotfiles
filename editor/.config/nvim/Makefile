.PHONY: test test-minimal test-verbose clean

# Run tests with plenary.nvim
test:
	@echo "🧪 Running Try API tests with plenary.nvim..."
	nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/')" -c "quit"

# Run tests with minimal output
test-minimal:
	@echo "🔍 Running tests (minimal output)..."
	nvim --headless -c "lua require('plenary.test_harness').test_directory('tests/', { minimal_init = 'tests/minimal_init.lua' })" -c "quit"

# Run tests with verbose output
test-verbose:
	@echo "📝 Running tests (verbose)..."
	nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua', verbose = true }" -c "quit"

# Run a specific test file
test-file:
	@echo "🎯 Running specific test file..."
	nvim --headless -c "PlenaryBustedFile tests/try_spec.lua { minimal_init = 'tests/minimal_init.lua' }" -c "quit"

# Development test command (interactive)
dev-test:
	@echo "🔧 Running tests in current nvim session..."
	@echo "Run: :PlenaryBustedDirectory tests/"

clean:
	@echo "🧹 Cleaning test artifacts..."
	@rm -f tests/.plenary_cache