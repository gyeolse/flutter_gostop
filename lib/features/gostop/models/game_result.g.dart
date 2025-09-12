// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameResultAdapter extends TypeAdapter<GameResult> {
  @override
  final int typeId = 0;

  @override
  GameResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameResult(
      gameDate: fields[0] as DateTime,
      players: (fields[1] as List).cast<PlayerResult>(),
      totalRounds: fields[2] as int,
      gameDurationMs: fields[3] as int,
      gameId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GameResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.gameDate)
      ..writeByte(1)
      ..write(obj.players)
      ..writeByte(2)
      ..write(obj.totalRounds)
      ..writeByte(3)
      ..write(obj.gameDurationMs)
      ..writeByte(4)
      ..write(obj.gameId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerResultAdapter extends TypeAdapter<PlayerResult> {
  @override
  final int typeId = 1;

  @override
  PlayerResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerResult(
      playerId: fields[0] as String,
      playerName: fields[1] as String,
      avatarPath: fields[2] as String,
      winCount: fields[3] as int,
      loseCount: fields[4] as int,
      finalAmount: fields[5] as int,
      highestScore: fields[6] as int,
      bestRoundNumber: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerResult obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.playerId)
      ..writeByte(1)
      ..write(obj.playerName)
      ..writeByte(2)
      ..write(obj.avatarPath)
      ..writeByte(3)
      ..write(obj.winCount)
      ..writeByte(4)
      ..write(obj.loseCount)
      ..writeByte(5)
      ..write(obj.finalAmount)
      ..writeByte(6)
      ..write(obj.highestScore)
      ..writeByte(7)
      ..write(obj.bestRoundNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SettlementAdapter extends TypeAdapter<Settlement> {
  @override
  final int typeId = 2;

  @override
  Settlement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settlement(
      from: fields[0] as String,
      to: fields[1] as String,
      amount: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Settlement obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
