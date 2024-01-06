"use client";
import { useContext, createContext } from "react";
import type { IPack } from "@/types";

export const PackContext = createContext<IPack>({
  name: "",
  path: "",
  title: "",
  uuid: "",
});

export function usePack() {
  const pack = useContext(PackContext);

  if (!pack) {
    throw new Error("No pack found in context");
  }

  return pack;
}
