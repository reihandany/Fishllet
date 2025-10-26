import React from 'react';
import { View, Text, StyleSheet, FlatList, SafeAreaView } from 'react-native';

const products = [
  { id: '1', name: 'Udang Kupas', price: 'Harga menyusul' },
  { id: '2', name: 'Cumi Tube/Cumi Ring', price: 'Harga menyusul' },
  { id: '3', name: 'Ikan Nila', price: 'Harga menyusul' },
  { id: '4', name: 'Ikan Dori', price: 'Harga menyusul' },
];

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.header}>Fishllet</Text>
      <FlatList
        data={products}
        keyExtractor={item => item.id}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text style={styles.productName}>{item.name}</Text>
            <Text style={styles.productPrice}>{item.price}</Text>
          </View>
        )}
      />
    </SafeAreaView>
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
