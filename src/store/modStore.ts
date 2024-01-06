"use client";

import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import type { IPack } from "@/types";

export interface ModState {
  packs: IPack[];
  addPack(pack: IPack): void;
  getPack(uuid: string): IPack | undefined;
}

export const useModStore = create<ModState>()(
  persist(
    (set, get) => ({
      packs: [] as IPack[],
      addPack: (pack: IPack) =>
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
      getPack: (uuid: string) => {
        return get().packs.find((pack) => pack.uuid === uuid);
      },
    }),
    {
      name: "mod-storage",
      storage: createJSONStorage(() => localStorage),
      partialize: ({ packs }) => ({
        packs,
      }),
    },
  ),
);
