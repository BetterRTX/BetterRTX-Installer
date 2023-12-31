"use client";

import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import type { Pack } from "@/types";

export interface ModState {
  packs: Pack[];
  addPack(pack: Pack): void;
}

export const useModStore = create<ModState>()(
  persist(
    (set) => ({
      packs: [] as Pack[],
      addPack: (pack: Pack) =>
        set((state) => {
          const existing = state.packs.find((p) => p.uuid === pack.uuid);

          if (existing) {
            existing.name = pack.name;
            existing.title = pack.title;
            existing.path = pack.path;
            return state;
          }

          state.packs.push(pack);

          return state;
        }),
    }),
    {
      name: "mod-storage",
      storage: createJSONStorage(() => localStorage),
    },
  ),
);
