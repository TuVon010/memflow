// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReviewStateCollection on Isar {
  IsarCollection<ReviewState> get reviewStates => this.collection();
}

const ReviewStateSchema = CollectionSchema(
  name: r'ReviewState',
  id: -6656946894520144595,
  properties: {
    r'cardId': PropertySchema(
      id: 0,
      name: r'cardId',
      type: IsarType.long,
    ),
    r'difficultyFactor': PropertySchema(
      id: 1,
      name: r'difficultyFactor',
      type: IsarType.double,
    ),
    r'due': PropertySchema(
      id: 2,
      name: r'due',
      type: IsarType.dateTime,
    ),
    r'lapses': PropertySchema(
      id: 3,
      name: r'lapses',
      type: IsarType.long,
    ),
    r'lastReview': PropertySchema(
      id: 4,
      name: r'lastReview',
      type: IsarType.dateTime,
    ),
    r'nextReview': PropertySchema(
      id: 5,
      name: r'nextReview',
      type: IsarType.dateTime,
    ),
    r'reps': PropertySchema(
      id: 6,
      name: r'reps',
      type: IsarType.long,
    ),
    r'reviewLog': PropertySchema(
      id: 7,
      name: r'reviewLog',
      type: IsarType.objectList,
      target: r'ReviewLogEntry',
    ),
    r'stability': PropertySchema(
      id: 8,
      name: r'stability',
      type: IsarType.double,
    )
  },
  estimateSize: _reviewStateEstimateSize,
  serialize: _reviewStateSerialize,
  deserialize: _reviewStateDeserialize,
  deserializeProp: _reviewStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'cardId': IndexSchema(
      id: -8501089313549364976,
      name: r'cardId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'cardId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'due': IndexSchema(
      id: -3213713132632231126,
      name: r'due',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'due',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'ReviewLogEntry': ReviewLogEntrySchema},
  getId: _reviewStateGetId,
  getLinks: _reviewStateGetLinks,
  attach: _reviewStateAttach,
  version: '3.1.0+1',
);

int _reviewStateEstimateSize(
  ReviewState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.reviewLog.length * 3;
  {
    final offsets = allOffsets[ReviewLogEntry]!;
    for (var i = 0; i < object.reviewLog.length; i++) {
      final value = object.reviewLog[i];
      bytesCount +=
          ReviewLogEntrySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _reviewStateSerialize(
  ReviewState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cardId);
  writer.writeDouble(offsets[1], object.difficultyFactor);
  writer.writeDateTime(offsets[2], object.due);
  writer.writeLong(offsets[3], object.lapses);
  writer.writeDateTime(offsets[4], object.lastReview);
  writer.writeDateTime(offsets[5], object.nextReview);
  writer.writeLong(offsets[6], object.reps);
  writer.writeObjectList<ReviewLogEntry>(
    offsets[7],
    allOffsets,
    ReviewLogEntrySchema.serialize,
    object.reviewLog,
  );
  writer.writeDouble(offsets[8], object.stability);
}

ReviewState _reviewStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReviewState(
    cardId: reader.readLongOrNull(offsets[0]) ?? 0,
    difficultyFactor: reader.readDoubleOrNull(offsets[1]) ?? 2.5,
    lapses: reader.readLongOrNull(offsets[3]) ?? 0,
    lastReview: reader.readDateTimeOrNull(offsets[4]),
    nextReview: reader.readDateTimeOrNull(offsets[5]),
    reps: reader.readLongOrNull(offsets[6]) ?? 0,
    stability: reader.readDoubleOrNull(offsets[8]) ?? 1.0,
  );
  object.due = reader.readDateTime(offsets[2]);
  object.id = id;
  object.reviewLog = reader.readObjectList<ReviewLogEntry>(
        offsets[7],
        ReviewLogEntrySchema.deserialize,
        allOffsets,
        ReviewLogEntry(),
      ) ??
      [];
  return object;
}

P _reviewStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readDoubleOrNull(offset) ?? 2.5) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 7:
      return (reader.readObjectList<ReviewLogEntry>(
            offset,
            ReviewLogEntrySchema.deserialize,
            allOffsets,
            ReviewLogEntry(),
          ) ??
          []) as P;
    case 8:
      return (reader.readDoubleOrNull(offset) ?? 1.0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reviewStateGetId(ReviewState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reviewStateGetLinks(ReviewState object) {
  return [];
}

void _reviewStateAttach(
    IsarCollection<dynamic> col, Id id, ReviewState object) {
  object.id = id;
}

extension ReviewStateByIndex on IsarCollection<ReviewState> {
  Future<ReviewState?> getByCardId(int cardId) {
    return getByIndex(r'cardId', [cardId]);
  }

  ReviewState? getByCardIdSync(int cardId) {
    return getByIndexSync(r'cardId', [cardId]);
  }

  Future<bool> deleteByCardId(int cardId) {
    return deleteByIndex(r'cardId', [cardId]);
  }

  bool deleteByCardIdSync(int cardId) {
    return deleteByIndexSync(r'cardId', [cardId]);
  }

  Future<List<ReviewState?>> getAllByCardId(List<int> cardIdValues) {
    final values = cardIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'cardId', values);
  }

  List<ReviewState?> getAllByCardIdSync(List<int> cardIdValues) {
    final values = cardIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cardId', values);
  }

  Future<int> deleteAllByCardId(List<int> cardIdValues) {
    final values = cardIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cardId', values);
  }

  int deleteAllByCardIdSync(List<int> cardIdValues) {
    final values = cardIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cardId', values);
  }

  Future<Id> putByCardId(ReviewState object) {
    return putByIndex(r'cardId', object);
  }

  Id putByCardIdSync(ReviewState object, {bool saveLinks = true}) {
    return putByIndexSync(r'cardId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCardId(List<ReviewState> objects) {
    return putAllByIndex(r'cardId', objects);
  }

  List<Id> putAllByCardIdSync(List<ReviewState> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'cardId', objects, saveLinks: saveLinks);
  }
}

extension ReviewStateQueryWhereSort
    on QueryBuilder<ReviewState, ReviewState, QWhere> {
  QueryBuilder<ReviewState, ReviewState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhere> anyCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'cardId'),
      );
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhere> anyDue() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'due'),
      );
    });
  }
}

extension ReviewStateQueryWhere
    on QueryBuilder<ReviewState, ReviewState, QWhereClause> {
  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> cardIdEqualTo(
      int cardId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cardId',
        value: [cardId],
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> cardIdNotEqualTo(
      int cardId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardId',
              lower: [],
              upper: [cardId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardId',
              lower: [cardId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardId',
              lower: [cardId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardId',
              lower: [],
              upper: [cardId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> cardIdGreaterThan(
    int cardId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'cardId',
        lower: [cardId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> cardIdLessThan(
    int cardId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'cardId',
        lower: [],
        upper: [cardId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> cardIdBetween(
    int lowerCardId,
    int upperCardId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'cardId',
        lower: [lowerCardId],
        includeLower: includeLower,
        upper: [upperCardId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> dueEqualTo(
      DateTime due) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'due',
        value: [due],
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> dueNotEqualTo(
      DateTime due) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'due',
              lower: [],
              upper: [due],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'due',
              lower: [due],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'due',
              lower: [due],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'due',
              lower: [],
              upper: [due],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> dueGreaterThan(
    DateTime due, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'due',
        lower: [due],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> dueLessThan(
    DateTime due, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'due',
        lower: [],
        upper: [due],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterWhereClause> dueBetween(
    DateTime lowerDue,
    DateTime upperDue, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'due',
        lower: [lowerDue],
        includeLower: includeLower,
        upper: [upperDue],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReviewStateQueryFilter
    on QueryBuilder<ReviewState, ReviewState, QFilterCondition> {
  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> cardIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      cardIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> cardIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> cardIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      difficultyFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficultyFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      difficultyFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficultyFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      difficultyFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficultyFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      difficultyFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficultyFactor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> dueEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'due',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> dueGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'due',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> dueLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'due',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> dueBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'due',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> lapsesEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lapses',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      lapsesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lapses',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> lapsesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lapses',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> lapsesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lapses',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      lastReviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReview',
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      lastReviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReview',
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      lastReviewEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      lastReviewGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      lastReviewLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      lastReviewBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      nextReviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextReview',
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      nextReviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextReview',
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      nextReviewEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      nextReviewGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      nextReviewLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      nextReviewBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextReview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> repsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reps',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> repsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reps',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> repsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reps',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition> repsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      reviewLogLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewLog',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      reviewLogIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewLog',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      reviewLogIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewLog',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      reviewLogLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewLog',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      reviewLogLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewLog',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      reviewLogLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewLog',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      stabilityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stability',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      stabilityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stability',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      stabilityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stability',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      stabilityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stability',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ReviewStateQueryObject
    on QueryBuilder<ReviewState, ReviewState, QFilterCondition> {
  QueryBuilder<ReviewState, ReviewState, QAfterFilterCondition>
      reviewLogElement(FilterQuery<ReviewLogEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'reviewLog');
    });
  }
}

extension ReviewStateQueryLinks
    on QueryBuilder<ReviewState, ReviewState, QFilterCondition> {}

extension ReviewStateQuerySortBy
    on QueryBuilder<ReviewState, ReviewState, QSortBy> {
  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy>
      sortByDifficultyFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyFactor', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy>
      sortByDifficultyFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyFactor', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByDue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'due', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByDueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'due', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByLapses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapses', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByLapsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapses', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByLastReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReview', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByLastReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReview', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReview', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByNextReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReview', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByStability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stability', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> sortByStabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stability', Sort.desc);
    });
  }
}

extension ReviewStateQuerySortThenBy
    on QueryBuilder<ReviewState, ReviewState, QSortThenBy> {
  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy>
      thenByDifficultyFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyFactor', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy>
      thenByDifficultyFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyFactor', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByDue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'due', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByDueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'due', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByLapses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapses', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByLapsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapses', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByLastReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReview', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByLastReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReview', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReview', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByNextReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReview', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByStability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stability', Sort.asc);
    });
  }

  QueryBuilder<ReviewState, ReviewState, QAfterSortBy> thenByStabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stability', Sort.desc);
    });
  }
}

extension ReviewStateQueryWhereDistinct
    on QueryBuilder<ReviewState, ReviewState, QDistinct> {
  QueryBuilder<ReviewState, ReviewState, QDistinct> distinctByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardId');
    });
  }

  QueryBuilder<ReviewState, ReviewState, QDistinct>
      distinctByDifficultyFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficultyFactor');
    });
  }

  QueryBuilder<ReviewState, ReviewState, QDistinct> distinctByDue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'due');
    });
  }

  QueryBuilder<ReviewState, ReviewState, QDistinct> distinctByLapses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lapses');
    });
  }

  QueryBuilder<ReviewState, ReviewState, QDistinct> distinctByLastReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReview');
    });
  }

  QueryBuilder<ReviewState, ReviewState, QDistinct> distinctByNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextReview');
    });
  }

  QueryBuilder<ReviewState, ReviewState, QDistinct> distinctByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reps');
    });
  }

  QueryBuilder<ReviewState, ReviewState, QDistinct> distinctByStability() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stability');
    });
  }
}

extension ReviewStateQueryProperty
    on QueryBuilder<ReviewState, ReviewState, QQueryProperty> {
  QueryBuilder<ReviewState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReviewState, int, QQueryOperations> cardIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardId');
    });
  }

  QueryBuilder<ReviewState, double, QQueryOperations>
      difficultyFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficultyFactor');
    });
  }

  QueryBuilder<ReviewState, DateTime, QQueryOperations> dueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'due');
    });
  }

  QueryBuilder<ReviewState, int, QQueryOperations> lapsesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lapses');
    });
  }

  QueryBuilder<ReviewState, DateTime?, QQueryOperations> lastReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReview');
    });
  }

  QueryBuilder<ReviewState, DateTime?, QQueryOperations> nextReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextReview');
    });
  }

  QueryBuilder<ReviewState, int, QQueryOperations> repsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reps');
    });
  }

  QueryBuilder<ReviewState, List<ReviewLogEntry>, QQueryOperations>
      reviewLogProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewLog');
    });
  }

  QueryBuilder<ReviewState, double, QQueryOperations> stabilityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stability');
    });
  }
}
