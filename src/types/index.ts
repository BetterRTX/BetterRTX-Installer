"use client";
export type InstanceName = "Minecraft" | "Minecraft Preview";

export interface Instance {
  location: string;
  name: string;
}

export type InstanceList = Record<InstanceName, Instance>;

export interface IPack {
  title: string;
  name: string;
  uuid: string;
  path: string;
}

type VersionVector = [number, number, number];

export interface IMinecraftManifest {
  format_version: number;
  header: {
    name: string;
    description: string;
    uuid: string;
    version: VersionVector;
    min_engine_version?: VersionVector;
  };
  modules: Array<{
    type: string;
    uuid: string;
    version: VersionVector;
  }>;
  dependencies?: Array<{
    uuid: string;
    version: VersionVector;
  }>;
  metadata?: {
    authors: string[];
    url?: string;
    license?: string;
    generated_with?: {
      [key: string]: VersionVector;
    };
  };
  subpacks?: Array<{
    folder_name: string;
    name: string;
    memory_tier: number;
    uuid?: string;
  }>;
}
