import React, { useState } from 'react';
import { View, Text, TextInput, Button, Image, TouchableOpacity } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import MapView, { Marker } from 'react-native-maps';
import { getFirestore, collection, addDoc } from 'firebase/firestore';
import { app } from './firebaseConfig';

const db = getFirestore(app);

export default function ReportScreen() {
    const [location, setLocation] = useState(null);
    const [description, setDescription] = useState('');
    const [image, setImage] = useState(null);

    const pickImage = async () => {
        let result = await ImagePicker.launchImageLibraryAsync({
            mediaTypes: ImagePicker.MediaTypeOptions.Images,
            allowsEditing: true,
            aspect: [4, 3],
            quality: 1,
        });
        if (!result.canceled) {
            setImage(result.uri);
        }
    };

    const submitReport = async () => {
        if (location && description) {
            await addDoc(collection(db, 'reports'), {
                location,
                description,
                image,
                status: 'pendente',
                timestamp: new Date()
            });
            alert('Denúncia enviada!');
            setLocation(null);
            setDescription('');
            setImage(null);
        } else {
            alert('Por favor, preencha todos os campos.');
        }
    };

    return (
        <View style={{ flex: 1, padding: 20 }}>
            <MapView 
                style={{ height: 300 }}
                onPress={(e) => setLocation(e.nativeEvent.coordinate)}
                initialRegion={{
                    latitude: -23.55052,
                    longitude: -46.633308,
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05,
                }}
            >
                {location && <Marker coordinate={location} />}
            </MapView>
            <Text>Descrição:</Text>
            <TextInput 
                value={description} 
                onChangeText={setDescription} 
                placeholder='Descreva o problema'
                style={{ borderWidth: 1, padding: 10, marginVertical: 10 }}
            />
            <TouchableOpacity onPress={pickImage}>
                <Text>Selecionar Imagem</Text>
            </TouchableOpacity>
            {image && <Image source={{ uri: image }} style={{ width: 100, height: 100 }} />}
            <Button title='Enviar Denúncia' onPress={submitReport} />
        </View>
    );
}
