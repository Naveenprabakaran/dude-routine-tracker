// lib/models/task_model.g.dart
// GENERATED CODE - This is manually written to match what build_runner would produce

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      name: fields[1] as String,
      timeLabel: fields[2] as String,
      hour: fields[3] as int,
      minute: fields[4] as int,
      date: fields[5] as String,
      status: fields[6] as String,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.timeLabel)
      ..writeByte(3)
      ..write(obj.hour)
      ..writeByte(4)
      ..write(obj.minute)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
