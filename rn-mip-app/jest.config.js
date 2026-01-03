module.exports = {
  // Use ts-jest for TypeScript support without React Native baggage
  transform: {
    '^.+\\.tsx?$': ['babel-jest', { presets: ['@babel/preset-typescript'] }],
  },
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.ts?(x)'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
};
