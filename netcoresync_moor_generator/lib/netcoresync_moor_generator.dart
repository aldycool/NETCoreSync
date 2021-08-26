/// NETCoreSync Moor Generator.
///
/// The code generation tool (as `dev_dependencies`) for the `netcoresync_moor`
/// package. Read the `netcoresync_moor`'s [README](https://github.com/aldycool/NETCoreSync/blob/master/netcoresync_moor/README.md)
/// for more details.

library netcoresync_moor_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/table_generator.dart';
import 'src/netcoresync_client_generator.dart';

Builder tableGeneratorBuilder(BuilderOptions builderOptions) => LibraryBuilder(
      TableGenerator(),
      generatedExtension: ".netcoresync_moor_table.part",
    );

Builder clientGeneratorBuilder(BuilderOptions builderOptions) =>
    SharedPartBuilder(
      [NetCoreSyncClientGenerator()],
      "netcoresync_moor_client",
    );
