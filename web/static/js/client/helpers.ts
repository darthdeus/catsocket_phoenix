const guid = (): string => {
  const s4 = () => {
    return Math.floor((1 + Math.random()) * 0x10000)
               .toString(16)
               .substring(1);

  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
         s4() + '-' + s4() + s4() + s4();
};

const user = () => {
    var storageKey = "__catsocket_user_id";

    // TODO - use cookies instead of localStorage
    var key = window.localStorage.getItem(storageKey);
    if (key) {
        return key;
    } else {
        key = guid();
        window.localStorage.setItem(storageKey, key);
        return key;
    }
};

const removeValue = function<T>(arr: T[], value: T) {
    var index = arr.indexOf(value);
    if (index !== -1) {
        arr.splice(index, 1);
    }
};

export {
  guid,
  user,
  removeValue,
};
