"use client";
import { useState } from "react";
import { RadioGroup } from "@headlessui/react";
import PackEntry from "@/components/mod/PackEntry";
import { Pack } from "@/types";

export default function PackList({ packs }: { packs: Pack[] }) {
  const [selectedPack, setSelectedPack] = useState<Pack | null>(null);

  return (
    <div className="card flex-grow divide-y divide-gray-700/50 bg-minecraft-slate-700/50 shadow-lg">
      <RadioGroup
        value={selectedPack}
        onChange={setSelectedPack}
        className="divide-y divide-gray-700/50"
      >
        {packs.map((pack) => (
          <RadioGroup.Option key={pack.path} value={pack}>
            <PackEntry pack={pack} />
          </RadioGroup.Option>
        ))}
      </RadioGroup>
    </div>
  );
}
