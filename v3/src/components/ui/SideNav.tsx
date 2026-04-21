import React from "react";
import { useTranslation } from "react-i18next";
import { useAppStore } from "../../store/appStore";
import { cx } from "classix";
import { DownloadIcon, Package, Wrench, Palette } from "lucide-react";
import Disclaimer from "../Disclaimer";

interface SideNavProps {
  className?: string;
  children?: React.ReactNode;
}

export const SideNav: React.FC<SideNavProps> = ({ className, children }) => {
  const { activeTab, setActiveTab } = useAppStore();
  const { t } = useTranslation();

  const navItems = [
    {
      id: "presets" as const,
      label: t("tab_presets"),
      icon: Package,
      description: t("presets_title"),
    },
    {
      id: "creator" as const,
      label: t("tab_creator"),
      icon: Palette,
      description: t("creator_title"),
    },
    {
      id: "actions" as const,
      label: t("tab_actions"),
      icon: Wrench,
      description: t("actions_title"),
    },
    {
      id: "installations" as const,
      label: t("tab_installations"),
      icon: DownloadIcon,
      description: t("installations_title"),
    },
  ];

  return (
    <div className={cx("sidebar-nav", className)}>
      <div className="sidebar-nav__header">
        <h2 className="sidebar-nav__title cursor-default">{t("currently_installed")}</h2>
      </div>
      {children}

      <div className="sidebar-nav__header">
        <h2 className="sidebar-nav__title cursor-default">{t("navigation")}</h2>
      </div>
      <div className="sidebar-nav__content">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;

          return (
            <button
              key={item.id}
              className={cx(
                "sidebar-nav__item",
                isActive ? "sidebar-nav__item--active" : "cursor-pointer"
              )}
              onClick={() => setActiveTab(item.id)}
              title={item.description}
            >
              <div className="sidebar-nav__item-icon">
                <Icon size={20} />
              </div>
              <div className="sidebar-nav__item-content">
                <span className="sidebar-nav__item-label">{item.label}</span>
                <span className="sidebar-nav__item-description">
                  {item.description}
                </span>
              </div>
            </button>
          );
        })}
      </div>

      <Disclaimer />
    </div>
  );
};
