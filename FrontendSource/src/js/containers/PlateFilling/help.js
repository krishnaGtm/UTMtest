import React from 'react';

export const wellSuggestions = (value, languages) => {
  const inputValue = value.trim().toLowerCase();
  const inputLength = inputValue.length;
  if (inputLength === 0) return [];
  return languages.filter(
    lang => lang.position.toLowerCase().slice(0, inputLength) === inputValue
  );
};
export const wellSuggestionValue = suggestion => suggestion.position;
export const wellSuggestion = suggestion => <div>{suggestion.position}</div>;
