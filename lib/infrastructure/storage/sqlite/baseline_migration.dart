import 'baseline_migration_sql.dart';
import 'migration_runner.dart';

const baselineMigration = Migration(
  version: 1,
  name: 'baseline',
  sql: baselineMigrationSql,
);

Migration loadBaselineMigration() => baselineMigration;
