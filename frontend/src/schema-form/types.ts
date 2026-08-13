export type DataType =
  | "STRING"
  | "NUMBER"
  | "BOOLEAN"
  | "DATE"
  | "ENUM"
  | "MULTI_ENUM"
  | "QUANTITY"
  | "GROUP";

export interface Rule {
  and?: Rule[];
  or?: Rule[];
  attribute?: string;
  operator?: "EQUALS" | "NOT_EQUALS" | "IN" | "NOT_IN" | "IS_EMPTY" | "IS_NOT_EMPTY";
  value?: unknown;
}

export interface AttributeSchema {
  code: string;
  label: string;
  description?: string | null;
  unit?: string | null;
  required?: boolean;
  dataType: DataType;
  enumValues?: string[] | null;
  defaultValue?: string | null;
  visibleWhen?: Rule | null;
  /** Ueberschreibt "required": Pflicht nur wenn die Bedingung erfuellt ist. */
  requiredWhen?: Rule | null;
  /** Code des Eltern-GROUP-Attributs, falls verschachtelt. Sonst null. */
  parentCode?: string | null;
  /** Nur bei dataType == GROUP relevant: kommt die Gruppe als Array (0..n) vor? */
  repeatable?: boolean;
  /** Code der GROUP, deren Variante dieses Attribut ist (oneOf). Sonst null. */
  variantOfCode?: string | null;
  /** Schluessel dieser Variante, z.B. "cartesian". Nur gesetzt wenn variantOfCode != null. */
  variantKey?: string | null;
}

export interface CategorySchema {
  categoryCode: string;
  categoryName?: string;
  attributes: AttributeSchema[];
}

/** Pfad-Segment in den verschachtelten Werten: Attribut-Code oder Array-Index (bei repeatable). */
export type PathSegment = string | number;

export interface AttributeNode {
  attr: AttributeSchema;
  /** Normale verschachtelte Kind-Attribute (keine Varianten). */
  children: AttributeNode[];
  /** Alternative Varianten-Gruppen (oneOf), ausgewaehlt ueber ein ENUM-Kind derselben Gruppe. */
  variants: AttributeNode[];
}