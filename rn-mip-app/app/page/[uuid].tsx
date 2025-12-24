import React from 'react';
import { useLocalSearchParams } from 'expo-router';
import { PageScreen } from '../../components/PageScreen';

export default function Page() {
  const { uuid } = useLocalSearchParams<{ uuid: string }>();
  
  if (!uuid) {
    return null;
  }

  return <PageScreen uuid={uuid} />;
}

