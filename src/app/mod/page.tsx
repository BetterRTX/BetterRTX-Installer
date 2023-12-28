"use client";
import { Tab } from "@headlessui/react";

export default function Page() {
  return (
    <main className="flex min-h-screen min-w-96 flex-col">
      <Tab.Group>
        <Tab.List className="flex space-x-1 rounded-xl bg-minecraft-slate-900/75 p-1">
          <Tab
            className={({ selected }) =>
              `w-full rounded-lg py-2.5 text-sm font-medium leading-5 text-white ${
                selected
                  ? "bg-minecraft-slate-800"
                  : "hover:bg-minecraft-slate-800"
              }`
            }
          >
            Setup
          </Tab>
          <Tab
            className={({ selected }) =>
              `w-full rounded-lg py-2.5 text-sm font-medium leading-5 text-white ${
                selected
                  ? "bg-minecraft-slate-800"
                  : "hover:bg-minecraft-slate-800"
              }`
            }
          >
            Instances
          </Tab>
        </Tab.List>
        <Tab.Panels className="mt-2">
          <Tab.Panel className="rounded-xl bg-minecraft-slate-800/75 p-3"></Tab.Panel>
          <Tab.Panel className="rounded-xl bg-minecraft-slate-800/75 p-3"></Tab.Panel>
        </Tab.Panels>
      </Tab.Group>
    </main>
  );
}
