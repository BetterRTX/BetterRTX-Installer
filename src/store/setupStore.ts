"use client";

import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

interface SetupState {
  unlockerProcess: string | null;
  unlockerArgs: string[] | null;
  setUnlockerProcess: (process: string) => void;
  setUnlockerArgs: (args: string[]) => void;
}

export const useSetupStore = create<SetupState>()(persist((set, get) => ({
  unlockerProcess: null,
  unlockerArgs: null,
  setUnlockerProcess: (process: string) => set({ unlockerProcess: process }),
  setUnlockerArgs: (args: string[]) => set({ unlockerArgs: args }),
}), {
  name: "setup-storage",
  storage: createJSONStorage(() => localStorage),
}));
