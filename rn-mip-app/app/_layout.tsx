import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <StatusBar style="auto" />
      <Stack
        screenOptions={{
          headerShown: false,
        }}
      >
        <Stack.Screen name="index" />
        <Stack.Screen 
          name="search"
          options={{
            presentation: 'modal',
            headerShown: false,
          }}
        />
        <Stack.Screen 
          name="page/[uuid]" 
          options={{ 
            headerShown: true,
            headerTitle: 'Page',
            headerBackTitle: 'Back',
            headerBackVisible: true,
          }} 
        />
      </Stack>
    </SafeAreaProvider>
  );
}

