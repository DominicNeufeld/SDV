interface UnitInfo {
  dimension: string;
  toBase: (v: number) => number;
  fromBase: (v: number) => number;
}

function linear(factor: number): Pick<UnitInfo, "toBase" | "fromBase"> {
  return {
    toBase: (v) => v * factor,
    fromBase: (v) => v / factor,
  };
}

export const UNITS: Record<string, UnitInfo> = {
  // Mass
  qg: { dimension: "mass", ...linear(1e-30) }, // quecto
  rg: { dimension: "mass", ...linear(1e-27) }, // ronto
  yg: { dimension: "mass", ...linear(1e-24) }, // yocto
  zg: { dimension: "mass", ...linear(1e-21) }, // zepto
  ag: { dimension: "mass", ...linear(1e-18) }, // atto
  fg: { dimension: "mass", ...linear(1e-15) }, // femto
  pg: { dimension: "mass", ...linear(1e-12) }, // pico
  ng: { dimension: "mass", ...linear(1e-9) }, // nano
  "µg": { dimension: "mass", ...linear(1e-6) }, // micro 
  mg: { dimension: "mass", ...linear(1e-3) }, // milli
  g: { dimension: "mass", ...linear(1) }, // gram
  kg: { dimension: "mass", ...linear(1e3) }, // kilo
  Mg: { dimension: "mass", ...linear(1e6) }, // mega
  Gg: { dimension: "mass", ...linear(1e9) }, // giga

  // Length 
  pm: { dimension: "length", ...linear(1e-12) },
  "Å": { dimension: "length", ...linear(1e-10) },
  nm: { dimension: "length", ...linear(1e-9) },
  "µm": { dimension: "length", ...linear(1e-6) },
  "μm": { dimension: "length", ...linear(1e-6) },
  mm: { dimension: "length", ...linear(1e-3) },
  cm: { dimension: "length", ...linear(1e-2) },
  m: { dimension: "length", ...linear(1) },

  // Volume 
  "µl": { dimension: "volume", ...linear(1e-6) },
  "μl": { dimension: "volume", ...linear(1e-6) },
  ml: { dimension: "volume", ...linear(1e-3) },
  "cm³": { dimension: "volume", ...linear(1e-3) },
  l: { dimension: "volume", ...linear(1) },
  "m³": { dimension: "volume", ...linear(1000) },

  // Pressure
  Pa: { dimension: "pressure", ...linear(1) },
  kPa: { dimension: "pressure", ...linear(1000) },
  mbar: { dimension: "pressure", ...linear(100) },
  bar: { dimension: "pressure", ...linear(100000) },
  atm: { dimension: "pressure", ...linear(101325) },
  psi: { dimension: "pressure", ...linear(6894.757) },

  // Temperature
  "°C": {
    dimension: "temperature",
    toBase: (c) => c + 273.15,
    fromBase: (k) => k - 273.15,
  },
  K: {
    dimension: "temperature",
    toBase: (k) => k,
    fromBase: (k) => k,
  },
  "°F": {
    dimension: "temperature",
    toBase: (f) => ((f - 32) * 5) / 9 + 273.15,
    fromBase: (k) => ((k - 273.15) * 9) / 5 + 32,
  },

  // Humidity
  "%RH": { dimension: "humidity", ...linear(1) },
};

// Rounding
function roundSmart(n: number): number {
  if (!Number.isFinite(n)) return n;
  return Number(n.toPrecision(6));
}


export function convertUnitValue(
  value: number,
  fromUnit: string,
  toUnit: string
): number | null {
  if (fromUnit === toUnit) return value;

  const from = UNITS[fromUnit];
  const to = UNITS[toUnit];
  if (!from || !to || from.dimension !== to.dimension) return null;

  return roundSmart(to.fromBase(from.toBase(value)));
}