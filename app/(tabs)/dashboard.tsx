import { View, Text, StyleSheet, SafeAreaView, ScrollView, TouchableOpacity } from 'react-native';
import { User, FileText, Download, Coins, TrendingUp, Calendar } from 'lucide-react-native';
import { useRouter } from 'expo-router';

const mockUserData = {
  name: 'John Doe',
  email: 'john.doe@eastdelta.edu.bd',
  studentId: 'EDU123456',
  semester: '7',
  totalCoins: 45,
  coinsEarned: 65,
  coinsSpent: 20,
  uploadedFiles: 8,
  downloadedFiles: 12,
  joinDate: 'September 2024',
};

const recentUploads = [
  { id: '1', title: 'Linear Algebra Notes', category: 'Mathematics', coins: 8, date: '2 days ago' },
  { id: '2', title: 'Python Programming Guide', category: 'Computer Science', coins: 6, date: '1 week ago' },
  { id: '3', title: 'Chemistry Lab Report', category: 'Chemistry', coins: 4, date: '2 weeks ago' },
];

const recentDownloads = [
  { id: '1', title: 'Calculus Study Guide', category: 'Mathematics', coins: 5, date: 'Yesterday' },
  { id: '2', title: 'Physics Formula Sheet', category: 'Physics', coins: 3, date: '3 days ago' },
  { id: '3', title: 'Essay Writing Tips', category: 'Literature', coins: 2, date: '1 week ago' },
];

export default function DashboardScreen() {
  const router = useRouter();

  const navigateToSettings = () => {
    router.push('/(tabs)/settings');
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text style={styles.welcomeText}>Welcome back,</Text>
            <Text style={styles.userName}>{mockUserData.name}</Text>
          </View>
          <TouchableOpacity style={styles.settingsButton} onPress={navigateToSettings}>
            <Text style={styles.settingsButtonText}>Settings</Text>
          </TouchableOpacity>
        </View>

        {/* Profile Card */}
        <View style={styles.profileCard}>
          <View style={styles.profileHeader}>
            <View style={styles.avatar}>
              <User size={32} color="#2563EB" />
            </View>
            <View style={styles.profileInfo}>
              <Text style={styles.profileName}>{mockUserData.name}</Text>
              <Text style={styles.profileEmail}>{mockUserData.email}</Text>
              <Text style={styles.profileId}>Student ID: {mockUserData.studentId}</Text>
              <Text style={styles.profileSemester}>Semester: {mockUserData.semester}</Text>
            </View>
          </View>
          <View style={styles.profileStats}>
            <Text style={styles.joinDate}>Member since {mockUserData.joinDate}</Text>
          </View>
        </View>

        {/* Stats Cards */}
        <View style={styles.statsGrid}>
          <View style={styles.statCard}>
            <View style={styles.statIcon}>
              <Coins size={20} color="#F59E0B" />
            </View>
            <Text style={styles.statValue}>{mockUserData.totalCoins}</Text>
            <Text style={styles.statLabel}>Total Coins</Text>
          </View>
          
          <View style={styles.statCard}>
            <View style={styles.statIcon}>
              <TrendingUp size={20} color="#10B981" />
            </View>
            <Text style={styles.statValue}>{mockUserData.coinsEarned}</Text>
            <Text style={styles.statLabel}>Coins Earned</Text>
          </View>
          
          <View style={styles.statCard}>
            <View style={styles.statIcon}>
              <FileText size={20} color="#2563EB" />
            </View>
            <Text style={styles.statValue}>{mockUserData.uploadedFiles}</Text>
            <Text style={styles.statLabel}>Uploaded</Text>
          </View>
          
          <View style={styles.statCard}>
            <View style={styles.statIcon}>
              <Download size={20} color="#8B5CF6" />
            </View>
            <Text style={styles.statValue}>{mockUserData.downloadedFiles}</Text>
            <Text style={styles.statLabel}>Downloaded</Text>
          </View>
        </View>

        {/* Recent Activity */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Recent Uploads</Text>
          {recentUploads.map((item) => (
            <View key={item.id} style={styles.activityItem}>
              <View style={styles.activityInfo}>
                <Text style={styles.activityTitle}>{item.title}</Text>
                <Text style={styles.activityCategory}>{item.category}</Text>
              </View>
              <View style={styles.activityMeta}>
                <View style={styles.coinsEarned}>
                  <Coins size={12} color="#10B981" />
                  <Text style={styles.coinsEarnedText}>+{item.coins}</Text>
                </View>
                <Text style={styles.activityDate}>{item.date}</Text>
              </View>
            </View>
          ))}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Recent Downloads</Text>
          {recentDownloads.map((item) => (
            <View key={item.id} style={styles.activityItem}>
              <View style={styles.activityInfo}>
                <Text style={styles.activityTitle}>{item.title}</Text>
                <Text style={styles.activityCategory}>{item.category}</Text>
              </View>
              <View style={styles.activityMeta}>
                <View style={styles.coinsSpent}>
                  <Coins size={12} color="#EF4444" />
                  <Text style={styles.coinsSpentText}>-{item.coins}</Text>
                </View>
                <Text style={styles.activityDate}>{item.date}</Text>
              </View>
            </View>
          ))}
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
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    paddingTop: 40,
  },
  welcomeText: {
    fontSize: 16,
    color: '#6B7280',
  },
  userName: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#111827',
  },
  settingsButton: {
    padding: 8,
  },
  profileCard: {
    backgroundColor: '#FFFFFF',
    margin: 20,
    borderRadius: 16,
    padding: 20,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  profileHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  avatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#EFF6FF',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  profileInfo: {
    flex: 1,
  },
  profileName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 2,
  },
  profileEmail: {
    fontSize: 14,
    color: '#6B7280',
    marginBottom: 2,
  },
  profileId: {
    fontSize: 12,
    color: '#9CA3AF',
    marginBottom: 2,
  },
  profileSemester: {
    fontSize: 12,
    color: '#9CA3AF',
  },
  profileStats: {
    borderTopWidth: 1,
    borderTopColor: '#E5E7EB',
    paddingTop: 16,
  },
  joinDate: {
    fontSize: 14,
    color: '#6B7280',
    textAlign: 'center',
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding: 20,
    gap: 12,
  },
  statCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
    width: '48%',
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  statIcon: {
    marginBottom: 8,
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 12,
    color: '#6B7280',
  },
  section: {
    paddingHorizontal: 20,
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 16,
  },
  activityItem: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 8,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  activityInfo: {
    flex: 1,
  },
  activityTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#111827',
    marginBottom: 2,
  },
  activityCategory: {
    fontSize: 12,
    color: '#059669',
  },
  activityMeta: {
    alignItems: 'flex-end',
  },
  coinsEarned: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 2,
    marginBottom: 2,
  },
  coinsEarnedText: {
    fontSize: 12,
    color: '#10B981',
    fontWeight: '600',
  },
  coinsSpent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 2,
    marginBottom: 2,
  },
  coinsSpentText: {
    fontSize: 12,
    color: '#EF4444',
    fontWeight: '600',
  },
  activityDate: {
    fontSize: 11,
    color: '#9CA3AF',
  },
});