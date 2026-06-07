import '../domain/verse_candidate.dart';

/// Diversificación estilo Maximal Marginal Relevance (MMR) sin
/// embeddings.
///
/// En el MVP, donde no tenemos embeddings, usamos una **proxy de
/// diversidad**: penalizamos candidatos que provengan del mismo libro
/// que uno ya seleccionado. La similitud se modela así:
///
///     sim(d, d') = 1 si mismo libro, 0 en caso contrario
///
/// Y la fórmula MMR queda:
///
///     mmr(d) = lambda * relevance(d)
///            - (1 - lambda) * max_{d' in S} sim(d, d')
///
/// Con `lambda` cercano a 1 favorecemos relevancia pura; con valores
/// cercanos a 0 favorecemos diversidad.
///
/// Complejidad: O(k * n) — para los tamaños del MVP (k=3, n<=50) es
/// despreciable.
class MmrSelector {
  const MmrSelector({this.lambda = 0.7});

  /// Peso de relevancia. Rango: [0.0, 1.0]. Default: 0.7.
  final double lambda;

  /// Selecciona hasta [k] candidatos maximizando la fórmula MMR.
  ///
  /// Si [candidates] tiene `k` o menos elementos, se devuelven todos
  /// (ordenados por score desc).
  ///
  /// El resultado está **ordenado por score desc** (no por orden de
  /// inserción) para que la UI presente primero el versículo más
  /// relevante.
  List<VerseCandidate> select(
    List<VerseCandidate> candidates,
    int k,
  ) {
    if (candidates.isEmpty) return <VerseCandidate>[];
    if (k <= 0) return <VerseCandidate>[];
    if (candidates.length <= k) {
      final List<VerseCandidate> sorted = List<VerseCandidate>.of(candidates)
        ..sort((VerseCandidate a, VerseCandidate b) =>
            b.score.compareTo(a.score));
      return sorted;
    }

    final List<VerseCandidate> pool = List<VerseCandidate>.of(candidates);
    final List<VerseCandidate> selected = <VerseCandidate>[];

    while (selected.length < k && pool.isNotEmpty) {
      VerseCandidate? best;
      double bestScore = double.negativeInfinity;

      for (int i = 0; i < pool.length; i++) {
        final VerseCandidate c = pool[i];
        final double rel = c.score;
        final double maxSim = _maxSimilarity(c, selected);
        final double mmrScore = lambda * rel - (1 - lambda) * maxSim;
        if (mmrScore > bestScore) {
          bestScore = mmrScore;
          best = c;
        }
      }

      if (best == null) break;
      selected.add(best);
      pool.remove(best);
    }

    selected.sort((VerseCandidate a, VerseCandidate b) =>
        b.score.compareTo(a.score));
    return selected;
  }

  /// Calcula la similitud máxima entre [c] y los candidatos ya
  /// seleccionados. En MVP: cuenta cuántos están en el mismo libro
  /// (proxy de similitud temática).
  double _maxSimilarity(VerseCandidate c, List<VerseCandidate> selected) {
    if (selected.isEmpty) return 0.0;
    int sameBook = 0;
    for (final VerseCandidate s in selected) {
      if (s.bookNumber == c.bookNumber) sameBook++;
    }
    return sameBook.toDouble();
  }
}
