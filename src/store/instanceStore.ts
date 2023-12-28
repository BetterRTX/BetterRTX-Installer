"use client";

import { create } from "zustand";
import type { InstanceList, InstanceName } from "@/types";

export interface SelectedInstanceState {
  selectedInstance: InstanceName | null;
  instances: InstanceList | null;
  instancesLoading: boolean;
  setInstance: (instance: InstanceName) => void;
}

export const useSetupInstanceStore = create<SelectedInstanceState>((set) => ({
  selectedInstance: null,
  instances: null,
  instancesLoading: true,
  setInstance: (instance: InstanceName) => set({ selectedInstance: instance }),
}));
