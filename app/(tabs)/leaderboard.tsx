import { View, Text, StyleSheet, SafeAreaView, ScrollView, TouchableOpacity } from 'react-native';
import { Trophy, Medal, Award, TrendingUp, User, Crown } from 'lucide-react-native';

const leaderboardData = [
  {
    id: '1',
    name: 'Sarah Johnson',
    university: 'MIT',
    coins: 342,
    uploads: 24,
    downloads: 89,
    rank: 1,
  },
  {
    id: '2',
    name: 'Alex Rodriguez',
    university: 'Stanford',
    coins: 298,
    uploads: 19,
    downloads: 67,
    rank: 2,
  },
  {
    id: '3',
    name: 'Emily Davis',
    university: 'Harvard',
    coins: 267,
    uploads: 22,
    downloads: 45,
    rank: 3,
  },
  {
    id: '4',
    name: 'Michael Chen',
    university: 'UC Berkeley',
    coins: 234,
    uploads: 18,
    downloads: 56,
    rank: 4,
  },
  {
    id: '5',
    name: 'Jessica Wilson',
    university: 'Yale',
    coins: 198,
    uploads: 15,
    downloads: 42,
    rank: 5,
  },
  {
    id: '6',
    name: 'David Kim',
    university: 'Princeton',
    coins: 187,
    uploads: 14,
    downloads: 38,
    rank: 6,
  },
  {
    id: '7',
    name: 'Ashley Brown',
    university: 'Columbia',
    coins: 165,
    uploads: 12,
    downloads: 35,
    rank: 7,
  },
  {
    id: '8',
    name: 'Ryan Taylor',
    university: 'Cornell',
    coins: 143,
    uploads: 11,
    downloads: 29,
    rank: 8,
  },
];

const currentUser = {
  name: 'John Doe',
  university: 'State University',
  coins: 45,
  uploads: 8,
  downloads: 12,
  rank: 156,
};

export default function LeaderboardScreen() {
  const getRankIcon = (rank: number) => {
    switch (rank) {
      case 1:
        return <Crown size={20} color="#F59E0B" />;
      case 2:
        return <Medal size={20} color="#9CA3AF" />;
      case 3:
        return <Award size={20} color="#D97706" />;
      default:
        return <Text style={styles.rankNumber}>{rank}</Text>;
    }
  };

  const getRankStyle = (rank: number) => {
    switch (rank) {
      case 1:
        return styles.firstPlace;
      case 2:
        return styles.secondPlace;
      case 3:
        return styles.thirdPlace;
      default:
        return styles.regularPlace;
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Leaderboard</Text>
        <View style={styles.headerIcon}>
          <Trophy size={24} color="#F59E0B" />
        </View>
      </View>

      {/* Current User Position */}
      <View style={styles.currentUserCard}>
        <View style={styles.currentUserHeader}>
          <Text style={styles.currentUserTitle}>Your Position</Text>
          <Text style={styles.currentUserRank}>#{currentUser.rank}</Text>
        </View>
        <View style={styles.currentUserStats}>
          <View style={styles.currentUserStat}>
            <Text style={styles.currentUserStatValue}>{currentUser.coins}</Text>
            <Text style={styles.currentUserStatLabel}>Coins</Text>
          </View>
          <View style={styles.currentUserStat}>
            <Text style={styles.currentUserStatValue}>{currentUser.uploads}</Text>
            <Text style={styles.currentUserStatLabel}>Uploads</Text>
          </View>
          <View style={styles.currentUserStat}>
            <Text style={styles.currentUserStatValue}>{currentUser.downloads}</Text>
            <Text style={styles.currentUserStatLabel}>Downloads</Text>
          </View>
        </View>
      </View>

      {/* Top Contributors */}
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>Top Contributors</Text>
        <TouchableOpacity style={styles.filterButton}>
          <Text style={styles.filterText}>This Month</Text>
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.leaderboardList}>
        {leaderboardData.map((user) => (
          <View key={user.id} style={[styles.leaderboardItem, getRankStyle(user.rank)]}>
            <View style={styles.rankContainer}>
              {getRankIcon(user.rank)}
            </View>
            
            <View style={styles.userInfo}>
              <Text style={styles.userName}>{user.name}</Text>
              <Text style={styles.userUniversity}>{user.university}</Text>
            </View>
            
            <View style={styles.userStats}>
              <View style={styles.statItem}>
                <Text style={styles.statValue}>{user.coins}</Text>
                <Text style={styles.statLabel}>coins</Text>
              </View>
              <View style={styles.statItem}>
                <Text style={styles.statValue}>{user.uploads}</Text>
                <Text style={styles.statLabel}>uploads</Text>
              </View>
            </View>
          </View>
        ))}
      </ScrollView>

      {/* Achievement Badges */}
      <View style={styles.achievementsSection}>
        <Text style={styles.achievementsTitle}>Achievement Badges</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.badgesList}>
          <View style={styles.badge}>
            <Trophy size={24} color="#F59E0B" />
            <Text style={styles.badgeText}>Top Contributor</Text>
          </View>
          <View style={styles.badge}>
            <TrendingUp size={24} color="#10B981" />
            <Text style={styles.badgeText}>Rising Star</Text>
          </View>
          <View style={styles.badge}>
            <Award size={24} color="#8B5CF6" />
            <Text style={styles.badgeText}>Quality Creator</Text>
          </View>
          <View style={styles.badge}>
            <Medal size={24} color="#EF4444" />
            <Text style={styles.badgeText}>Super Sharer</Text>
          </View>
        </ScrollView>
      </View>
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
  headerIcon: {
    padding: 8,
  },
  currentUserCard: {
    backgroundColor: '#FFFFFF',
    margin: 20,
    borderRadius: 16,
    padding: 20,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  currentUserHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  currentUserTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#374151',
  },
  currentUserRank: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2563EB',
  },
  currentUserStats: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  currentUserStat: {
    alignItems: 'center',
  },
  currentUserStatValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#111827',
  },
  currentUserStatLabel: {
    fontSize: 12,
    color: '#6B7280',
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
  },
  filterButton: {
    backgroundColor: '#EFF6FF',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  filterText: {
    fontSize: 12,
    color: '#2563EB',
    fontWeight: '600',
  },
  leaderboardList: {
    flex: 1,
    paddingHorizontal: 20,
  },
  leaderboardItem: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 8,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  firstPlace: {
    backgroundColor: '#FFFBEB',
    borderColor: '#F59E0B',
  },
  secondPlace: {
    backgroundColor: '#F8FAFC',
    borderColor: '#9CA3AF',
  },
  thirdPlace: {
    backgroundColor: '#FEF3E2',
    borderColor: '#D97706',
  },
  regularPlace: {
    backgroundColor: '#FFFFFF',
    borderColor: '#E5E7EB',
  },
  rankContainer: {
    width: 40,
    alignItems: 'center',
    marginRight: 12,
  },
  rankNumber: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#6B7280',
  },
  userInfo: {
    flex: 1,
  },
  userName: {
    fontSize: 16,
    fontWeight: '600',
    color: '#111827',
    marginBottom: 2,
  },
  userUniversity: {
    fontSize: 12,
    color: '#6B7280',
  },
  userStats: {
    flexDirection: 'row',
    gap: 16,
  },
  statItem: {
    alignItems: 'center',
  },
  statValue: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#111827',
  },
  statLabel: {
    fontSize: 10,
    color: '#6B7280',
  },
  achievementsSection: {
    padding: 20,
  },
  achievementsTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 12,
  },
  badgesList: {
    flexDirection: 'row',
  },
  badge: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 12,
    alignItems: 'center',
    marginRight: 12,
    minWidth: 80,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  badgeText: {
    fontSize: 10,
    color: '#6B7280',
    textAlign: 'center',
    marginTop: 4,
  },
});