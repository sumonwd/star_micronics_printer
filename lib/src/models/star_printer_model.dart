enum StarPrinterModel {
  tsp100,
  tsp650,
  tsp700,
  tsp800,
  mcp21,
  mcp31,
  mcp20,
  mcp30,
  sp700,
  sm_s210i,
  sm_s220i,
  sm_s230i,
  sm_t300i,
  sm_t400i,
  sm_l200,
  sm_l300,
  bsc10,
  unknown;

  static StarPrinterModel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'tsp100':
        return StarPrinterModel.tsp100;
      case 'tsp650':
        return StarPrinterModel.tsp650;
      case 'tsp700':
        return StarPrinterModel.tsp700;
      case 'tsp800':
        return StarPrinterModel.tsp800;
      case 'mcp21':
        return StarPrinterModel.mcp21;
      case 'mcp31':
        return StarPrinterModel.mcp31;
      case 'mcp20':
        return StarPrinterModel.mcp20;
      case 'mcp30':
        return StarPrinterModel.mcp30;
      case 'sp700':
        return StarPrinterModel.sp700;
      case 'sm-s210i':
        return StarPrinterModel.sm_s210i;
      case 'sm-s220i':
        return StarPrinterModel.sm_s220i;
      case 'sm-s230i':
        return StarPrinterModel.sm_s230i;
      case 'sm-t300i':
        return StarPrinterModel.sm_t300i;
      case 'sm-t400i':
        return StarPrinterModel.sm_t400i;
      case 'sm-l200':
        return StarPrinterModel.sm_l200;
      case 'sm-l300':
        return StarPrinterModel.sm_l300;
      case 'bsc10':
        return StarPrinterModel.bsc10;
      default:
        return StarPrinterModel.unknown;
    }
  }
}
