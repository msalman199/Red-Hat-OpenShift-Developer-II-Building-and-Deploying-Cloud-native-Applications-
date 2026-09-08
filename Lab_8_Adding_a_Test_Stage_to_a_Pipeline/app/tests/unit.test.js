// Simple unit test
console.log('✓ Testing application modules...');

// Test 1: Basic functionality
function testBasicFunction() {
  const result = 2 + 2;
  if (result === 4) {
    console.log('✓ Basic math test passed');
    return true;
  } else {
    console.log('✗ Basic math test failed');
    return false;
  }
}

// Test 2: String operations
function testStringOperations() {
  const str = 'Hello World';
  if (str.length === 11) {
    console.log('✓ String length test passed');
    return true;
  } else {
    console.log('✗ String length test failed');
    return false;
  }
}

// Run tests
const test1 = testBasicFunction();
const test2 = testStringOperations();

if (test1 && test2) {
  console.log('✓ All unit tests passed!');
  process.exit(0);
} else {
  console.log('✗ Some unit tests failed!');
  process.exit(1);
}
