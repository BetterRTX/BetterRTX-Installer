"use client";
export type InstanceName = "Minecraft" | "Minecraft Preview";

export type InstanceList = Record<
  InstanceName,
  { location: string; name: string }
>;

export interface Pack {
  title: string;
  name: string;
  uuid: string;
  path: string;
}
