class PermissionSwitch {
  constructor(user, domElement) {
    this.user = user;
    this.id = domElement.data().id;
    this.switchtype = domElement.data().switchtype;
    this.attribute = domElement.data().attribute;
    this.inputDomElement = domElement.find('input');
    this.checked = this.inputDomElement.prop('checked');
    this.disabled = this.inputDomElement.prop('disabled');
  }

  changeDisableSwitches(state) {
    $(`div[data-id=${this.id}][data-switchtype=last_only].permission-switch`).find('input').prop("checked", false);
    $(`div[data-id=${this.id}].disable`).find('input').prop("disabled", state);
  }
}

class LocalSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions) {
    super(user, domElement);
    this.permission = _.find(permissions, _.matchesProperty('id', this.id));
    this.attributeState = this.permission[this.attribute];
  }

  toggleSwitch() {
    COPO.permissions.iconToggle(this.switchtype, this.id);
    if (this.switchtype === "disallowed") {
      this.changeDisableSwitches(this.checked);
    }
    this.permission[this.attribute] = this.nextState();
    $.ajax({
      url: `/users/${this.user}/devices/${this.permission['device_id']}/permissions/${this.id}`,
      type: 'PUT',
      dataType: 'script',
      data: { permission: this.permission }
    });
  }

  nextState() {
    if(this.attributeState === "disallowed") {
      return "complete"
    } else if(this.switchtype === "disallowed") {
      return "disallowed"
    } else if(this.attributeState === "complete") {
      return "last_only"
    } else if(this.attributeState === "last_only") {
      return "complete"
    } else {
      return !this.attributeState
    }
  }
}

class MasterSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions, idType) {
    super(user, domElement);
    this.permissions = permissions.filter(_.matchesProperty(idType, this.id));
  }

  toggleSwitch() {
    this.permissions.forEach(function(permission) {
      const P_DOM_ELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${this.switchtype}].permission-switch`);
      const P_SWITCH = new LocalSwitch(this.user, P_DOM_ELEMENT, this.permissions);
      if ((P_SWITCH.disabled && P_SWITCH.switchtype === 'last_only')){
        this.inputDomElement.prop("checked", false)
      } else if (this.checked !== P_SWITCH.checked) {
        P_SWITCH.inputDomElement.prop("checked", this.checked);
        P_SWITCH.checked = this.checked;
        P_SWITCH.toggleSwitch();
      }
    }, this);
  }

  setState() {
    const SWITCHES_CHECKED = [];

    this.permissions.forEach(function(permission){
      const P_DOM_ELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${this.switchtype}].permission-switch`);
      SWITCHES_CHECKED.push(P_DOM_ELEMENT.find('input').prop("checked"))
    }, this)
    const NEW_MASTER_CHECKED_STATE = _.every(SWITCHES_CHECKED)
    this.inputDomElement.prop("checked", NEW_MASTER_CHECKED_STATE)

    if (this.switchtype === "disallowed") {
      $(`div[data-id=${this.id}][data-switchtype=last_only].master`).find('input').prop("checked", false);
      const MASTERS = $(`div[data-id=${this.id}].disable.master`).find('input');
      MASTERS.prop("disabled", NEW_MASTER_CHECKED_STATE);
    }
  }
}
