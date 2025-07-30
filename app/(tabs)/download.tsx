import { useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, TextInput, ScrollView, Alert } from 'react-native';
import { Search, Filter, FileText, Download, Coins } from 'lucide-react-native';

const mockResources = [
  {
    id: '1',
    title: 'Calculus II Study Guide',
    description: 'Comprehensive study guide covering integration techniques',
    category: 'Mathematics',
    type: 'PDF',
    coins: 5,
    author: 'Sarah Johnson',
    downloads: 45,
  },
  {
    id: '2',
    title: 'Physics Lab Report Template',
    description: 'Professional template for physics lab reports',
    category: 'Physics',
    type: 'DOC',
    coins: 3,
    author: 'Mike Chen',
    downloads: 23,
  },
  {
    id: '3',
    title: 'Organic Chemistry Reactions',
    description: 'Visual guide to common organic chemistry reactions',
    category: 'Chemistry',
    type: 'Image',
    coins: 4,
    author: 'Emily Davis',
    downloads: 67,
  },
  {
    id: '4',
    title: 'Data Structures Notes',
    description: 'Complete notes on data structures and algorithms',
    category: 'Computer Science',
    type: 'PDF',
    coins: 6,
    author: 'Alex Rodriguez',
    downloads: 89,
  },
  {
    id: '5',
    title: 'Shakespeare Analysis',
    description: 'In-depth analysis of Hamlet and Macbeth',
    category: 'Literature',
    type: 'DOC',
    coins: 4,
    author: 'Jessica Wilson',
    downloads: 34,
  },
];

export default function DownloadScreen() {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [userCoins] = useState(25);

  const categories = ['All', 'Mathematics', 'Physics', 'Chemistry', 'Computer Science', 'Literature'];

  const filteredResources = mockResources.filter(resource => {
    const matchesSearch = resource.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         resource.description.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'All' || resource.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const handleDownload = (resource: any) => {
    if (userCoins >= resource.coins) {
      Alert.alert(
        'Download Resource',
        `Download "${resource.title}" for ${resource.coins} coins?`,
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Download', onPress: () => {
            Alert.alert('Success', `Downloaded ${resource.title}!`);
          }}
        ]
      );
    } else {
      Alert.alert('Insufficient Coins', 'You need more coins to download this resource.');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Download Resources</Text>
        <View style={styles.coinsContainer}>
          <Coins size={20} color="#F59E0B" />
          <Text style={styles.coinsText}>{userCoins} coins</Text>
        </View>
      </View>

      <View style={styles.searchContainer}>
        <View style={styles.searchBar}>
          <Search size={20} color="#6B7280" />
          <TextInput
            style={styles.searchInput}
            placeholder="Search resources..."
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
        </View>
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.categoryScroll}>
        {categories.map((category) => (
          <TouchableOpacity
            key={category}
            style={[
              styles.categoryChip,
              selectedCategory === category && styles.categoryChipActive
            ]}
            onPress={() => setSelectedCategory(category)}
          >
            <Text style={[
              styles.categoryText,
              selectedCategory === category && styles.categoryTextActive
            ]}>
              {category}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      <ScrollView style={styles.resourcesList}>
        {filteredResources.map((resource) => (
          <View key={resource.id} style={styles.resourceCard}>
            <View style={styles.resourceHeader}>
              <View style={styles.resourceInfo}>
                <Text style={styles.resourceTitle}>{resource.title}</Text>
                <Text style={styles.resourceAuthor}>by {resource.author}</Text>
              </View>
              <View style={styles.resourceType}>
                <FileText size={16} color="#6B7280" />
                <Text style={styles.resourceTypeText}>{resource.type}</Text>
              </View>
            </View>
            
            <Text style={styles.resourceDescription}>{resource.description}</Text>
            
            <View style={styles.resourceFooter}>
              <View style={styles.resourceStats}>
                <Text style={styles.resourceCategory}>{resource.category}</Text>
                <Text style={styles.resourceDownloads}>{resource.downloads} downloads</Text>
              </View>
              
              <TouchableOpacity
                style={[
                  styles.downloadButton,
                  userCoins < resource.coins && styles.downloadButtonDisabled
                ]}
                onPress={() => handleDownload(resource)}
              >
                <Coins size={16} color="#FFFFFF" />
                <Text style={styles.downloadButtonText}>{resource.coins}</Text>
                <Download size={16} color="#FFFFFF" />
              </TouchableOpacity>
            </View>
          </View>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F9FAFB',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    paddingTop: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#111827',
  },
  coinsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FEF3C7',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    gap: 4,
  },
  coinsText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#D97706',
  },
  searchContainer: {
    paddingHorizontal: 20,
    marginBottom: 16,
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    gap: 12,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: '#111827',
  },
  categoryScroll: {
    paddingHorizontal: 20,
    marginBottom: 16,
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
  resourcesList: {
    flex: 1,
    paddingHorizontal: 20,
  },
  resourceCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  resourceHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  resourceInfo: {
    flex: 1,
  },
  resourceTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 2,
  },
  resourceAuthor: {
    fontSize: 12,
    color: '#6B7280',
  },
  resourceType: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  resourceTypeText: {
    fontSize: 12,
    color: '#6B7280',
  },
  resourceDescription: {
    fontSize: 14,
    color: '#374151',
    marginBottom: 12,
  },
  resourceFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  resourceStats: {
    flex: 1,
  },
  resourceCategory: {
    fontSize: 12,
    color: '#059669',
    fontWeight: '600',
    marginBottom: 2,
  },
  resourceDownloads: {
    fontSize: 12,
    color: '#6B7280',
  },
  downloadButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2563EB',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
    gap: 4,
  },
  downloadButtonDisabled: {
    backgroundColor: '#9CA3AF',
  },
  downloadButtonText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '600',
  },
});