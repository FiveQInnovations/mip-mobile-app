import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="auto" />
      <Stack
        screenOptions={{
          headerShown: false,
        }}
      >
        <Stack.Screen name="index" />
        <Stack.Screen 
          name="page/[uuid]" 
          options={{ 
            headerShown: true,
            headerTitle: 'Page', // Will be overridden by page title if possible, or just stay as Page
            headerBackTitle: 'Back'
          }} 
        />
      </Stack>
    </>
  );
}

