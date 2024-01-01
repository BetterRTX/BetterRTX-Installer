"use client";
import clsx from "clsx";
import { Fragment, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { Menu, Transition } from "@headlessui/react";
import { Pack } from "@/types";
import { useSetupStore } from "@/store/setupStore";
import { TriangleDownIcon } from "@radix-ui/react-icons";
import { useMinecraftProcess } from "@/hooks";

function SideloadEntryMenu({ uuid }: { uuid: Pack["uuid"] }) {
  const { t } = useTranslation();
  const { sideloadInstances } = useSetupStore();
  const handleInstall = () => {
    // TODO
  };

  const instanceList = Object.keys(sideloadInstances).map((key) => ({
    key,
    ...sideloadInstances[key],
  }));

  return (
    <div className="relative">
      <Menu>
        {({ open }) => (
          <>
            <Menu.Button
              className={clsx(
                open && "rounded-br-none",
                "btn inline-flex justify-between divide-x divide-gray-400/50 bg-minecraft-green-700/50 py-0 shadow-md hover:bg-minecraft-green-700 sm:w-72 sm:flex-1",
              )}
            >
              <span className="flex-grow overflow-hidden truncate">
                <span className="leading-relaxed text-gray-100">
                  {t("mod.installSideloadInstance")}
                </span>
              </span>

              <TriangleDownIcon className="block h-6 w-6 flex-shrink fill-gray-100 pl-2" />
            </Menu.Button>
            <Transition
              enter="transition duration-100 ease-out"
              enterFrom="opacity-0"
              enterTo="opacity-100"
              leave="duration-75 ease-out"
              leaveFrom="opacity-100"
              leaveTo="opacity-0"
            >
              <Menu.Items className="absolute right-0 top-6 z-20 mt-1 w-56 divide-y divide-gray-600/50 rounded-b-md border border-minecraft-slate-100/90 bg-minecraft-slate-200/80 shadow-lg backdrop-blur-md">
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
          </>
        )}
      </Menu>
    </div>
  );
}

function UnlockerEntryMenu({ uuid }: { uuid: Pack["uuid"] }) {
  const { t } = useTranslation();
  const { getLocations, getInstanceName } = useMinecraftProcess();
  const handleInstall = () => {
    // TODO
  };

  const [locations, setLocations] = useState<Record<string, string>>({});

  useEffect(() => {
    getLocations().then(setLocations);
  }, [getLocations]);

  return (
    <div className="relative">
      <Menu>
        {({ open }) => (
          <>
            <Menu.Button
              className={clsx(
                open && "rounded-br-none",
                "btn inline-flex flex-grow justify-between divide-x divide-gray-300/30 bg-minecraft-purple-700/50 py-0 shadow-md hover:bg-minecraft-purple-700/80 active:rounded-br-none sm:w-64 sm:flex-1",
              )}
            >
              <span className="flex-grow overflow-hidden truncate pl-1 pr-2">
                <span className="leading-relaxed text-gray-100">
                  {t("mod.installUnlockerInstance")}
                </span>
              </span>

              <TriangleDownIcon className="block h-6 w-6 flex-shrink fill-gray-100 pl-2" />
            </Menu.Button>
            <Transition
              enter="transition duration-100 ease-out"
              enterFrom="opacity-0"
              enterTo=" opacity-100"
              leave="transition duration-75 ease-out"
              leaveFrom=" opacity-100"
              leaveTo="opacity-0"
              as={Fragment}
            >
              <Menu.Items className="absolute right-0 top-6 z-20 mt-1 w-56 divide-y divide-gray-600/50 rounded-b-md border border-minecraft-slate-100/90 bg-minecraft-slate-200/80 shadow-lg backdrop-blur-md">
                {Object.entries(locations).map(([instance, location]) => (
                  <Menu.Item key={instance}>
                    <button
                      className="inline-flex w-full px-4 py-2 text-left text-sm text-gray-800"
                      onClick={() => handleInstall()}
                      title={location}
                    >
                      <span className="font-medium">
                        {getInstanceName(instance)}
                      </span>
                    </button>
                  </Menu.Item>
                ))}
              </Menu.Items>
            </Transition>
          </>
        )}
      </Menu>
    </div>
  );
}

export default function PackEntry({ pack }: { pack: Pack }) {
  const { t } = useTranslation();
  return (
    <div className="flex justify-start space-x-2 p-4">
      <div className="mb-auto overflow-hidden rounded-md border border-gray-400/50 shadow-sm">
        <img
          src={
            new URL(`https://bedrock.graphics/api/pack/${pack.uuid}/icon`).href
          }
          alt={pack.title}
          width={96}
          height={96}
          className="aspect-square cursor-pointer object-cover shadow-sm"
        />
      </div>
      <div className="flex flex-1 flex-col space-y-0.5 py-2.5 pl-4 pr-0">
        <h5 className="cursor-pointer select-none font-medium text-gray-200 ui-checked:text-minecraft-blue-400">
          {pack.title}
        </h5>
        <h6 className="select-none text-sm font-normal text-gray-400/75">
          {t("mod.installLabel")}
        </h6>

        <div className="mt-4 flex flex-1 flex-col items-end space-x-4 space-y-2 pr-4 sm:mt-0 sm:flex-row sm:justify-start sm:space-y-0">
          <UnlockerEntryMenu uuid={pack.uuid} />
          <SideloadEntryMenu uuid={pack.uuid} />
        </div>
      </div>
    </div>
  );
}
