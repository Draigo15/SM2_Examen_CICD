import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/episode.dart';
import '../l10n/app_localizations.dart';

class EpisodeProvider with ChangeNotifier {
  final Chapter _currentChapter = Chapter.getSampleChapter();
  int? _selectedEpisodeId;

  Chapter get currentChapter => _currentChapter;
  int? get selectedEpisodeId => _selectedEpisodeId;

  Episode? getEpisodeById(int id) {
    try {
      return _currentChapter.episodes.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  bool canPlayEpisode(int episodeId) {
    final episode = getEpisodeById(episodeId);
    if (episode == null) return false;
    
    return episode.status == EpisodeStatus.completed || 
           episode.status == EpisodeStatus.current;
  }

  void selectEpisode(int episodeId) {
    if (canPlayEpisode(episodeId)) {
      _selectedEpisodeId = episodeId;
      notifyListeners();
    }
  }

  void playEpisode(int episodeId) {
    if (canPlayEpisode(episodeId)) {
      _selectedEpisodeId = episodeId;

      for (int i = 0; i < _currentChapter.episodes.length; i++) {
        final ep = _currentChapter.episodes[i];
        if (ep.id == episodeId) {
          _currentChapter.episodes[i] = Episode(
            id: ep.id,
            title: ep.title,
            difficulty: ep.difficulty,
            status: EpisodeStatus.current,
            description: ep.description,
            progress: ep.progress,
          );
        } else if (ep.status == EpisodeStatus.current && ep.id != episodeId) {
          // Mantener otros episodios actuales como completados si ya estaban al 100%
          _currentChapter.episodes[i] = Episode(
            id: ep.id,
            title: ep.title,
            difficulty: ep.difficulty,
            status: ep.progress >= 1.0 ? EpisodeStatus.completed : ep.status,
            description: ep.description,
            progress: ep.progress,
          );
        }
      }

      notifyListeners();
      debugPrint('Playing episode $episodeId');
    }
  }

  String getTooltipMessage(BuildContext context, Episode episode) {
    switch (episode.status) {
      case EpisodeStatus.completed:
        return AppLocalizations.of(context)!.episodeCompleted;
      case EpisodeStatus.current:
        return AppLocalizations.of(context)!.continueEpisode;
      case EpisodeStatus.locked:
        return AppLocalizations.of(context)!.completePreviousEpisode;
    }
  }

  void completeEpisode(int episodeId) {
    for (int i = 0; i < _currentChapter.episodes.length; i++) {
      final ep = _currentChapter.episodes[i];
      if (ep.id == episodeId) {
        // Marcar como completado
        _currentChapter.episodes[i] = Episode(
          id: ep.id,
          title: ep.title,
          difficulty: ep.difficulty,
          status: EpisodeStatus.completed,
          description: ep.description,
          progress: 1.0,
        );

        // Desbloquear el siguiente episodio
        if (i + 1 < _currentChapter.episodes.length) {
          final next = _currentChapter.episodes[i + 1];
          _currentChapter.episodes[i + 1] = Episode(
            id: next.id,
            title: next.title,
            difficulty: next.difficulty,
            status: EpisodeStatus.current,
            description: next.description,
            progress: next.progress,
          );
          _selectedEpisodeId = next.id;
        }
        break;
      }
    }

    notifyListeners();
  }

  void updateProgress(int episodeId, double newProgress) {
    for (int i = 0; i < _currentChapter.episodes.length; i++) {
      final ep = _currentChapter.episodes[i];
      if (ep.id == episodeId && ep.status != EpisodeStatus.locked) {
        final clamped = newProgress.clamp(0.0, 1.0);
        _currentChapter.episodes[i] = Episode(
          id: ep.id,
          title: ep.title,
          difficulty: ep.difficulty,
          status: clamped >= 1.0 ? EpisodeStatus.completed : ep.status,
          description: ep.description,
          progress: clamped,
        );

        // Si se completó al actualizar progreso, desbloquear el siguiente
        if (clamped >= 1.0 && i + 1 < _currentChapter.episodes.length) {
          final next = _currentChapter.episodes[i + 1];
          _currentChapter.episodes[i + 1] = Episode(
            id: next.id,
            title: next.title,
            difficulty: next.difficulty,
            status: EpisodeStatus.current,
            description: next.description,
            progress: next.progress,
          );
          _selectedEpisodeId = next.id;
        }
        break;
      }
    }

    notifyListeners();
  }

  void resetChapterForRepetition(int chapterId) {
    // Reset all episodes to allow repetition without affecting original score
    // This is a mock implementation - in a real app, this would communicate with backend
    
    for (int i = 0; i < _currentChapter.episodes.length; i++) {
      final episode = _currentChapter.episodes[i];
      
      // Reset episode status for repetition
      // Keep the first episode as current, others as locked
      if (i == 0) {
        _currentChapter.episodes[i] = Episode(
          id: episode.id,
          title: episode.title,
          difficulty: episode.difficulty,
          status: EpisodeStatus.current,
          description: episode.description,
          progress: 0.0,
        );
      } else {
        _currentChapter.episodes[i] = Episode(
          id: episode.id,
          title: episode.title,
          difficulty: episode.difficulty,
          status: EpisodeStatus.locked,
          description: episode.description,
          progress: 0.0,
        );
      }
    }
    
    // Reset selected episode
    _selectedEpisodeId = null;
    
    // Notify listeners to update UI
    notifyListeners();
    
    debugPrint('Chapter ${_currentChapter.title} reset for repetition');
  }
}
