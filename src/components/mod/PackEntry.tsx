"use client";
import clsx from "clsx";
import { Menu, Transition } from "@headlessui/react";
import { Pack } from "@/types";
import { useSetupStore } from "@/store/setupStore";

function EntryMenu({ uuid }: { uuid: Pack["uuid"] }) {
  const { sideloadInstances, unlockerProcess } = useSetupStore();
  const handleInstall = () => {
    // TODO
  };

  const instanceList = Object.keys(sideloadInstances).map((key) => ({
    key,
    ...sideloadInstances[key],
  }));

  return (
    <Menu>
      <Menu.Button className="btn">...</Menu.Button>
      <Transition
        enter="transition duration-100 ease-out"
        enterFrom="transform scale-95 opacity-0"
        enterTo="transform scale-100 opacity-100"
        leave="transition duration-75 ease-out"
        leaveFrom="transform scale-100 opacity-100"
        leaveTo="transform scale-95 opacity-0"
      >
        <Menu.Items className="absolute z-20 divide-y divide-gray-600 rounded-md border border-minecraft-slate-600/50 bg-minecraft-slate-400/90 shadow-lg backdrop-blur-md">
          {instanceList.map((instance) => (
            <Menu.Item key={instance.key}>
              <button
                className="inline-flex w-full px-4 py-2 text-left text-sm text-gray-700"
                onClick={() => handleInstall()}
              >
                <span className="font-medium">{instance.key}</span>
                {instance.preview ? (
                  <span className="text-xs text-gray-500">Preview</span>
                ) : (
                  <span className="text-xs">Minecraft</span>
                )}
              </button>
            </Menu.Item>
          ))}
        </Menu.Items>
      </Transition>
    </Menu>
  );
}

export default function PackEntry({ pack }: { pack: Pack }) {
  return (
    <div className="flex px-4 py-3">
      <div className="flex flex-col space-y-0.5 pr-4">
        <h5 className="font-medium text-gray-200 ui-checked:text-minecraft-blue-400">
          {pack.title}
        </h5>
      </div>
      <div className="flex flex-col">
        <EntryMenu uuid={pack.uuid} />
      </div>
    </div>
  );
}
