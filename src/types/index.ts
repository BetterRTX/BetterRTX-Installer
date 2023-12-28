"use client";
export type InstanceName = "Minecraft" | "Minecraft Preview";

export type InstanceList = Record<
  InstanceName,
  { location: string; name: string }
>;
