"use client";
import { useEffect, useState } from "react";
import { usePathname } from "next/navigation";
import Link from "next/link";
import { Menu } from "@headlessui/react";
import { useMinecraftProcess } from "@/hooks/useMinecraftProcess";
import { useSetupInstanceStore } from "@/store/instanceStore";
import type { InstanceList, InstanceName } from "@/types";

export default function InstanceMenu() {
  const pathname = usePathname();
  const { selectedInstance, setInstance } = useSetupInstanceStore();
  const { getInstanceList } = useMinecraftProcess();
  const [instanceList, setInstanceList] = useState<InstanceList | null>(null);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    getInstanceList().then(setInstanceList).catch(setError);
  }, [getInstanceList]);

  const handleClick = (instanceName: string) => {
    setInstance(instanceName as InstanceName);
  };

  return (
    <div className="flex flex-col space-y-2">
      <Menu>
        <Menu.Button className="px-3 py-2 rounded-md text-sm font-medium hover:bg-minecraft-slate-800/50 transition-all duration-100 ease-out">
          <span>Manage Instances</span>
        </Menu.Button>
        <Menu.Items className="absolute right-0 w-48 mt-2 origin-top-right bg-minecraft-slate-900/75 divide-y divide-white rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
          {Object.keys(instanceList ?? {}).map((instanceName) => (
            <Menu.Item key={instanceName}>
              <button
                type="button"
                onClick={() =>
                  handleClick(instanceName)}
              >
                {instanceName}
              </button>
            </Menu.Item>
          ))}
        </Menu.Items>
      </Menu>
      {error && <p className="error-message">{error.toString()}</p>}
    </div>
  );
}
