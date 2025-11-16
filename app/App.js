import React from 'react';
import { View, Text, StyleSheet, FlatList, SafeAreaView } from 'react-native';
import Register from './pages/Register';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

const products = [
  { id: '1', name: 'Udang Kupas', price: 'Harga menyusul' },
  { id: '2', name: 'Cumi Tube/Cumi Ring', price: 'Harga menyusul' },
  { id: '3', name: 'Ikan Nila', price: 'Harga menyusul' },
  { id: '4', name: 'Ikan Dori', price: 'Harga menyusul' },
];

const Stack = createStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Login" component={Login} />
        <Stack.Screen name="Register" component={Register} />
        <Stack.Screen name="Home" component={App} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#2380c4', // warna biru sesuai logo
    paddingHorizontal: 16,
    paddingTop: 40,
  },
  header: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 24,
    textAlign: 'center',
    fontFamily: 'sans-serif',
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    marginBottom: 16,
    elevation: 2,
  },
  productName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2380c4',
  },
  productPrice: {
    fontSize: 16,
    color: '#555',
    marginTop: 8,
  },
});
