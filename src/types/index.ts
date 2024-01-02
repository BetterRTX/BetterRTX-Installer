"use client";
export type InstanceName = "Minecraft" | "Minecraft Preview";

export interface Instance {
  location: string;
  name: string;
}

export type InstanceList = Record<InstanceName, Instance>;

export interface Pack {
  title: string;
  name: string;
  uuid: string;
  path: string;
}
