part of '../trip_leg_detail_screen.dart';

extension _FeedStatus on _TripLegDetailScreenState {
  Future<void> _retryRealtimeFeeds() => _refreshLegData(forceRefresh: true);
}
