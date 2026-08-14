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
  operator?:
    | "EQUALS"
    | "NOT_EQUALS"
    | "IN"
    | "NOT_IN"
    | "IS_EMPTY"
    | "IS_NOT_EMPTY"
    | "CONTAINS"
    | "NOT_CONTAINS";
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
  requiredWhen?: Rule | null;
  parentCode?: string | null;
  repeatable?: boolean;
  variantOfCode?: string | null;
  variantKey?: string | null;
}

export interface CategorySchema {
  categoryCode: string;
  categoryName?: string;
  attributes: AttributeSchema[];
}

export type PathSegment = string | number;

export interface AttributeNode {
  attr: AttributeSchema;
  children: AttributeNode[];
  variants: AttributeNode[];
}