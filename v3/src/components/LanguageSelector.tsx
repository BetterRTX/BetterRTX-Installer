import React, { memo } from 'react';
import { Globe } from 'lucide-react';

interface LanguageSelectorProps {
  currentLanguage: string;
  onLanguageChange: (e: React.ChangeEvent<HTMLSelectElement>) => void;
  translatorDebugLabel: string;
}

function LanguageSelector({ 
  currentLanguage, 
  onLanguageChange, 
  translatorDebugLabel 
}: LanguageSelectorProps) {
  return (
    <div className="language-select">
      <select 
        id="language-select"
        value={currentLanguage}
        onChange={onLanguageChange}
      >
        <option value="en">English</option>
        <option value="zh-CN">简体中文</option> 
        {/* <option value="fr">Français</option>
        <option value="de">Deutsch</option>
        <option value="es">Español</option>
        <option value="it">Italiano</option>
        <option value="pt">Português</option>
        <option value="ru">Русский</option>*/}
        <option value="cimode">{translatorDebugLabel}</option>
      </select>
      <Globe className="language-menu-icon" size={16} />
    </div>
  );
}

export default memo(LanguageSelector);
