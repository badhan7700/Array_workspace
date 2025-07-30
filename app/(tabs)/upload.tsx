import { useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, TextInput, ScrollView, Alert } from 'react-native';
import { Upload, FileText, Image, File, Plus } from 'lucide-react-native';

const categories = [
  'Mathematics',
  'Physics',
  'Chemistry',
  'Biology',
  'Computer Science',
  'Engineering',
  'Literature',
  'History',
  'Economics',
  'Psychology',
];

export default function UploadScreen() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('');
  const [selectedFile, setSelectedFile] = useState<string | null>(null);

  const handleFileSelect = (type: string) => {
    setSelectedFile(type);
    Alert.alert('File Selection', `${type} file selected (Demo)`);
  };

  const handleUpload = () => {
    if (!title || !description || !category || !selectedFile) {
      Alert.alert('Error', 'Please fill in all fields and select a file');
      return;
    }
    
    Alert.alert('Success', 'File uploaded successfully! You earned 10 coins.', [
      { text: 'OK', onPress: () => {
        setTitle('');
        setDescription('');
        setCategory('');
        setSelectedFile(null);
      }}
    ]);
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.header}>
          <Text style={styles.title}>Upload Resource</Text>
          <Text style={styles.subtitle}>Share your academic materials</Text>
        </View>

        <View style={styles.form}>
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Title</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter resource title"
              value={title}
              onChangeText={setTitle}
            />
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Description</Text>
            <TextInput
              style={[styles.input, styles.textArea]}
              placeholder="Describe your resource"
              value={description}
              onChangeText={setDescription}
              multiline
              numberOfLines={4}
            />
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Category</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.categoryScroll}>
              {categories.map((cat) => (
                <TouchableOpacity
                  key={cat}
                  style={[
                    styles.categoryChip,
                    category === cat && styles.categoryChipActive
                  ]}
                  onPress={() => setCategory(cat)}
                >
                  <Text style={[
                    styles.categoryText,
                    category === cat && styles.categoryTextActive
                  ]}>
                    {cat}
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>File Type</Text>
            <View style={styles.fileTypes}>
              <TouchableOpacity
                style={[
                  styles.fileTypeCard,
                  selectedFile === 'PDF' && styles.fileTypeCardActive
                ]}
                onPress={() => handleFileSelect('PDF')}
              >
                <FileText size={24} color={selectedFile === 'PDF' ? '#2563EB' : '#6B7280'} />
                <Text style={[
                  styles.fileTypeText,
                  selectedFile === 'PDF' && styles.fileTypeTextActive
                ]}>
                  PDF
                </Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[
                  styles.fileTypeCard,
                  selectedFile === 'DOC' && styles.fileTypeCardActive
                ]}
                onPress={() => handleFileSelect('DOC')}
              >
                <File size={24} color={selectedFile === 'DOC' ? '#2563EB' : '#6B7280'} />
                <Text style={[
                  styles.fileTypeText,
                  selectedFile === 'DOC' && styles.fileTypeTextActive
                ]}>
                  DOC
                </Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[
                  styles.fileTypeCard,
                  selectedFile === 'Image' && styles.fileTypeCardActive
                ]}
                onPress={() => handleFileSelect('Image')}
              >
                <Image size={24} color={selectedFile === 'Image' ? '#2563EB' : '#6B7280'} />
                <Text style={[
                  styles.fileTypeText,
                  selectedFile === 'Image' && styles.fileTypeTextActive
                ]}>
                  Image
                </Text>
              </TouchableOpacity>
            </View>
          </View>

          <TouchableOpacity style={styles.uploadButton} onPress={handleUpload}>
            <Upload size={20} color="#FFFFFF" />
            <Text style={styles.uploadButtonText}>Upload Resource</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F9FAFB',
  },
  scrollView: {
    flex: 1,
  },
  header: {
    padding: 20,
    paddingTop: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 16,
    color: '#6B7280',
  },
  form: {
    padding: 20,
    gap: 20,
  },
  inputGroup: {
    gap: 8,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#374151',
  },
  input: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  textArea: {
    height: 100,
    textAlignVertical: 'top',
  },
  categoryScroll: {
    marginTop: 8,
  },
  categoryChip: {
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    marginRight: 8,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  categoryChipActive: {
    backgroundColor: '#2563EB',
    borderColor: '#2563EB',
  },
  categoryText: {
    fontSize: 14,
    color: '#6B7280',
  },
  categoryTextActive: {
    color: '#FFFFFF',
  },
  fileTypes: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 8,
  },
  fileTypeCard: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    gap: 8,
  },
  fileTypeCardActive: {
    borderColor: '#2563EB',
    backgroundColor: '#EFF6FF',
  },
  fileTypeText: {
    fontSize: 14,
    color: '#6B7280',
  },
  fileTypeTextActive: {
    color: '#2563EB',
    fontWeight: '600',
  },
  uploadButton: {
    backgroundColor: '#2563EB',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    borderRadius: 12,
    gap: 8,
    marginTop: 20,
  },
  uploadButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
});